import { Injectable, UnauthorizedException, ConflictException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Inject } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'crypto';
import { RegisterDto, LoginDto, RefreshDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
    @Inject('DATABASE_CONNECTION') private db: any,
  ) {}

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

      return {
        success: true,
        data: {
          user: {
            id: userId,
            email,
            name,
            role: 'USER',
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
      'SELECT id, email, password_hash, name, role, is_active FROM users WHERE email = ?',
      [email]
    );

    const user = (users as any[])[0];

    if (!user || !user.is_active) {
      throw new UnauthorizedException('Invalid credentials');
    }

    // Verify password
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      throw new UnauthorizedException('Invalid credentials');
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

      if (!user || !user.is_active) {
        throw new UnauthorizedException('User not found or inactive');
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
