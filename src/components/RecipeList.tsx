import type { Recipe } from "../types";

type RecipeListProps = {
  recipes: Recipe[]
  loading: boolean
  errorMessage: string
}

function RecipeList({ recipes, loading, errorMessage }: RecipeListProps) {

  function displayRecipes() {
    return (
      <ul>
        {recipes.map((recipe) => (
          <li key={recipe.recipe_id}>
            <strong>{recipe.name}</strong>
            {recipe.description ? <p>{recipe.description}</p> : null}
            <p>Servings: {recipe.servings}</p>
            {recipe.cooking_time_minutes !== null ? <p>Cooking Time (Minutes): {recipe.cooking_time_minutes}</p> : null}
          </li>
        ))}
      </ul>
    )
  }

  return(
    <>
      {loading ? <p>Loading</p> :
        errorMessage ? <p>{errorMessage}</p> :
          recipes.length === 0 ? <p>No recipes</p> :
            displayRecipes()}
    </>
  );
}

export default RecipeList