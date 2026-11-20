import { useEffect, useState } from "react";
import { supabase } from "../lib/supabase";

type Recipe = {
  recipe_id: string
  user_id: string
  name: string
  cooking_time_minutes: number | null
  servings: number
  description: string | null
  created_at: string
}

function RecipeList() {
  const [recipes, setRecipes] = useState<Recipe[]>([]);
  const [errorMessage, setErrorMessage] = useState('');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
      supabase.from('recipes').select().order('created_at', { ascending: false }).then(({ data, error }) => {
          if(error) {
              setErrorMessage(error.message)
          } else {
              setRecipes(data)
          }
          setLoading(false)
      })
  }, []);

  function displayRecipes() {
    return (
      <ul>
        {recipes.map((recipe) => (
          <li key={recipe.recipe_id}>
            <strong>{recipe.name}</strong>
            <p>{recipe.description ? recipe.description + "\n" : null}</p>
            <p>Servings: {recipe.servings}</p>
            <p>{recipe.cooking_time_minutes !== null ? "Cooking Time (Minutes):" + recipe.cooking_time_minutes: null}</p>
          </li>
        ))}
      </ul>
    )
  }

  return(
    <>
      {loading ? <p>Loading</p> : (recipes.length === 0 && !errorMessage) ? <p>No recipes</p> : displayRecipes()}
      {errorMessage &&
        <p>{errorMessage}</p>}
    </>
  );
}

export default RecipeList