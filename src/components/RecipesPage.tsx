import { useState, useEffect } from "react";
import { supabase } from "../lib/supabase";
import type { Recipe } from "../types";
import RecipeList from "./RecipeList";

function RecipesPage() {
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

  return (
    <>
      <RecipeList recipes={recipes} errorMessage={errorMessage} loading={loading} />
    </>
  )
}

export default RecipesPage;