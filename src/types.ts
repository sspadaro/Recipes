export type Recipe = {
  recipe_id: string
  user_id: string
  name: string
  cooking_time_minutes: number | null
  servings: number
  description: string | null
  created_at: string
}