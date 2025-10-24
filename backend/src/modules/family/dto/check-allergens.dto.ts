export class CheckAllergensDto {
  recipeId: string;
}

export interface AllergenConflict {
  memberId: string;
  memberName: string;
  memberAgeGroup: string;
  conflictingIngredients: {
    ingredientId: string;
    ingredientName: string;
  }[];
}

export interface CheckAllergensResponse {
  success: boolean;
  hasConflicts: boolean;
  conflicts: AllergenConflict[];
  message?: string;
}

