import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy, ExtractJwt } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { Inject } from '@nestjs/common';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    @Inject('DATABASE_CONNECTION') private db: any,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get('JWT_SECRET') || 'default-secret',
    });
  }

  async validate(payload: any) {
    // Check if user still exists and is active
    const [users] = await this.db.execute(
      'SELECT id, email, name, role, is_active FROM users WHERE id = ?',
      [payload.userId]
    );

    const user = (users as any[])[0];

    if (!user || !user.is_active) {
      throw new UnauthorizedException('User not found or inactive');
    }

    return {
      id: user.id,
      userId: user.id,
      email: user.email,
      name: user.name,
      role: user.role,
    };
  }
}
