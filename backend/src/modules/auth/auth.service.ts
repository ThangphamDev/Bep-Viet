import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Inject } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';
import { RegisterDto, LoginDto, RefreshDto } from './dto/auth.dto';
import { OAuth2Client } from 'google-auth-library';

@Injectable()
export class AuthService {
  private googleClient: OAuth2Client;

  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
    @Inject('DATABASE_CONNECTION') private db: any,
  ) {
    // Initialize Google OAuth2 Client
    this.googleClient = new OAuth2Client(
      this.configService.get('GOOGLE_CLIENT_ID'),
    );
  }

  async register(registerDto: RegisterDto) {
    try {
      const { email, password, name, region, subregion } = registerDto;

      // Check if user already exists
      const [existingUsers] = await this.db.execute(
        'SELECT id FROM users WHERE email = ?',
        [email]
      );

      if ((existingUsers as any[]).length > 0) {
        throw new ConflictException('User already exists');
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 12);

      // Create user
      const userId = randomUUID();
      const userRegion = region || 'BAC';
      const userSubregion = subregion || null;
      
      console.log('Register params:', { userId, email, name, userRegion, userSubregion });
      
      await this.db.execute(
        `INSERT INTO users (id, email, password_hash, name, region, subregion, role, is_active)
         VALUES (?, ?, ?, ?, ?, ?, 'USER', 1)`,
        [userId, email, passwordHash, name, userRegion, userSubregion]
      );

      // Create user preferences
      await this.db.execute(
        `INSERT INTO user_preferences (user_id, household_size, spicy_level, taste_spicy, taste_salty, taste_sweet, taste_light)
         VALUES (?, 2, 2, 2, 2, 2, 2)`,
        [userId]
      );

      // Generate tokens
      const accessToken = this.generateAccessToken(userId, email, 'USER');
      const refreshToken = this.generateRefreshToken(userId, email, 'USER');

      // Get created user with all fields
      const [createdUsers] = await this.db.execute(
        'SELECT id, email, name, role, region, subregion, is_active, created_at, updated_at FROM users WHERE id = ?',
        [userId]
      );
      const createdUser = (createdUsers as any[])[0];

      return {
        success: true,
        data: {
          user: {
            id: createdUser.id,
            email: createdUser.email,
            name: createdUser.name,
            role: createdUser.role,
            region: createdUser.region,
            subregion: createdUser.subregion,
            is_active: createdUser.is_active,
            created_at: createdUser.created_at,
            updated_at: createdUser.updated_at,
          },
          accessToken,
          refreshToken,
        },
      };
    } catch (error) {
      console.error('Register error:', error);
      throw new BadRequestException('Registration failed: ' + error.message);
    }
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Find user
    const [users] = await this.db.execute(
      'SELECT id, email, password_hash, name, role, region, subregion, is_active, created_at, updated_at FROM users WHERE email = ?',
      [email]
    );

    const user = (users as any[])[0];

    // Check if user exists
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Check if account is active
    if (!user.is_active || user.is_active === 0) {
      throw new UnauthorizedException('Your account has been blocked by administrator. Please contact support for assistance.');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      throw new UnauthorizedException('Invalid email or password');
    }

    // Generate tokens
    const accessToken = this.generateAccessToken(user.id, user.email, user.role);
    const refreshToken = this.generateRefreshToken(user.id, user.email, user.role);

    return {
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          region: user.region,
          subregion: user.subregion,
          is_active: user.is_active,
          created_at: user.created_at,
          updated_at: user.updated_at,
        },
        accessToken,
        refreshToken,
      },
    };
  }

  async refresh(refreshDto: RefreshDto) {
    const { refreshToken } = refreshDto;

    try {
      // Verify refresh token
      const decoded = this.jwtService.verify(refreshToken, {
        secret: this.configService.get('REFRESH_SECRET'),
      });

      if (decoded.type !== 'refresh') {
        throw new UnauthorizedException('Invalid token type');
      }

      // Check if user still exists and is active
      const [users] = await this.db.execute(
        'SELECT id, email, role, is_active FROM users WHERE id = ?',
        [decoded.userId]
      );

      const user = (users as any[])[0];

      if (!user) {
        throw new UnauthorizedException('User not found');
      }

      if (!user.is_active || user.is_active === 0) {
        throw new UnauthorizedException('Your account has been blocked by administrator. Please contact support for assistance.');
      }

      // Generate new access token
      const newAccessToken = this.generateAccessToken(user.id, user.email, user.role);

      return {
        success: true,
        data: {
          accessToken: newAccessToken,
        },
      };
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async loginWithGoogle(idToken: string) {
    try {
      console.log('=== Google Login Started ===');
      console.log('ID Token received:', idToken?.substring(0, 50) + '...');
      console.log('GOOGLE_CLIENT_ID:', this.configService.get('GOOGLE_CLIENT_ID'));
      
      // Verify Google ID token
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: this.configService.get('GOOGLE_CLIENT_ID'),
      });

      const payload = ticket.getPayload();
      if (!payload) {
        throw new UnauthorizedException('Invalid Google token');
      }
      
      console.log('Google payload:', { email: payload.email, name: payload.name, sub: payload.sub });

      const { email, name, sub: googleId, picture } = payload;

      // Check if user exists
      const [users] = await this.db.execute(
        'SELECT id, email, name, role, region, subregion, is_active, created_at, updated_at FROM users WHERE email = ?',
        [email]
      );

      let user = (users as any[])[0];

      if (user) {
        // User exists - check if active
        if (!user.is_active || user.is_active === 0) {
          throw new UnauthorizedException('Your account has been blocked by administrator. Please contact support for assistance.');
        }
      } else {
        // User doesn't exist - create new account
        const userId = randomUUID();
        const now = new Date();
        await this.db.execute(
          `INSERT INTO users (id, email, password_hash, name, region, role, is_active, created_at)
           VALUES (?, ?, ?, ?, 'BAC', 'USER', 1, ?)`,
          [userId, email, '', name || 'Google User', now] // Empty password for Google users
        );

        // Create user preferences
        await this.db.execute(
          `INSERT INTO user_preferences (user_id, household_size, spicy_level, taste_spicy, taste_salty, taste_sweet, taste_light)
           VALUES (?, 2, 2, 2, 2, 2, 2)`,
          [userId]
        );

        user = {
          id: userId,
          email,
          name: name || 'Google User',
          role: 'USER',
          region: 'BAC',
          subregion: null,
          is_active: 1,
          created_at: now,
          updated_at: null,
        };
      }

      // Generate tokens
      const accessToken = this.generateAccessToken(user.id, user.email, user.role);
      const refreshToken = this.generateRefreshToken(user.id, user.email, user.role);

      console.log('Google login successful for user:', user.email);

      return {
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            role: user.role,
            region: user.region,
            subregion: user.subregion,
            is_active: user.is_active,
            created_at: user.created_at,
            updated_at: user.updated_at,
          },
          accessToken,
          refreshToken,
        },
      };
    } catch (error) {
      console.error('=== Google login error ===');
      console.error('Error message:', error.message);
      console.error('Error stack:', error.stack);
      throw new UnauthorizedException('Google authentication failed');
    }
  }

  async logout() {
    // In a real application, you might want to blacklist the token
    return {
      success: true,
      message: 'Logged out successfully',
    };
  }

  private generateAccessToken(userId: string, email: string, role: string): string {
    return this.jwtService.sign(
      { userId, email, role, type: 'access' },
      {
        secret: this.configService.get('JWT_SECRET'),
        expiresIn: this.configService.get('JWT_EXPIRES'),
      }
    );
  }

  private generateRefreshToken(userId: string, email: string, role: string): string {
    return this.jwtService.sign(
      { userId, email, role, type: 'refresh' },
      {
        secret: this.configService.get('REFRESH_SECRET'),
        expiresIn: this.configService.get('REFRESH_EXPIRES'),
      }
    );
  }
}
