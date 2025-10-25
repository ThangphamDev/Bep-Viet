import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AppConfigModule } from './config/config.module';
import { DatabaseModule } from './database/database.module';
import { RedisModule } from './modules/redis/redis.module';
import { StorageModule } from './modules/storage/storage.module';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { RegionsModule } from './modules/regions/regions.module';
import { SeasonsModule } from './modules/seasons/seasons.module';
import { IngredientsModule } from './modules/ingredients/ingredients.module';
import { PricesModule } from './modules/prices/prices.module';
import { RecipesModule } from './modules/recipes/recipes.module';
import { SuggestionsModule } from './modules/suggestions/suggestions.module';
import { MealPlansModule } from './modules/meal-plans/meal-plans.module';
import { PantryModule } from './modules/pantry/pantry.module';
import { ShoppingModule } from './modules/shopping/shopping.module';
import { CommunityModule } from './modules/community/community.module';
import { CommentsModule } from './modules/comments/comments.module';
import { RatingsModule } from './modules/ratings/ratings.module';
import { FamilyModule } from './modules/family/family.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { ModerationModule } from './modules/moderation/moderation.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';
import { GeminiModule } from './modules/gemini/gemini.module';
import { PaymentsModule } from './modules/payments/payments.module';

@Module({
  imports: [
    AppConfigModule,
    DatabaseModule,
    RedisModule,
    StorageModule,
    AuthModule,
    UsersModule,
    RegionsModule,
    SeasonsModule,
    IngredientsModule,
    PricesModule,
    RecipesModule,
    SuggestionsModule,
    MealPlansModule,
    PantryModule,
    ShoppingModule,
    CommunityModule,
    CommentsModule,
    RatingsModule,
    FamilyModule,
    AnalyticsModule,
    ModerationModule,
    SubscriptionsModule,
    PaymentsModule,
    GeminiModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}