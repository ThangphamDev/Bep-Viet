import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AppConfigModule } from './config/config.module';
import { DatabaseModule } from './database/database.module';
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
import { AdvisoryModule } from './modules/advisory/advisory.module';
import { AnalyticsModule } from './modules/analytics/analytics.module';
import { ModerationModule } from './modules/moderation/moderation.module';
import { SubscriptionsModule } from './modules/subscriptions/subscriptions.module';

@Module({
  imports: [
    AppConfigModule,
    DatabaseModule,
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
    AdvisoryModule,
    AnalyticsModule,
    ModerationModule,
    SubscriptionsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}