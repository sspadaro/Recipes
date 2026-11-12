-- RLS policies for Recipe Organizer.
-- Already applied to the live database. Re-running will fail
-- with "policy already exists" unless you drop them first.

-- Policies for the 'recipes' table
create policy select_recipes on recipes
for select
to authenticated
using (true);

create policy insert_recipes on recipes
for insert
to authenticated 
with check ((select auth.uid()) = user_id);

create policy update_recipes on recipes
for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy delete_recipes on recipes
for delete
to authenticated 
using ((select auth.uid()) = user_id);

-- Policies for the 'recipe_steps' table
create policy select_recipe_steps on recipe_steps
for select
to authenticated
using (true);

create policy insert_recipe_steps on recipe_steps
for insert
to authenticated
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_steps.recipe_id and (select auth.uid()) = recipes.user_id));

create policy update_recipe_steps on recipe_steps
for update
to authenticated 
using (exists (select 1 from recipes where recipes.recipe_id = recipe_steps.recipe_id and (select auth.uid()) = recipes.user_id))
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_steps.recipe_id and (select auth.uid()) = recipes.user_id));

create policy delete_recipe_steps on recipe_steps
for delete
to authenticated
using (exists (select 1 from recipes where recipes.recipe_id = recipe_steps.recipe_id and (select auth.uid()) = recipes.user_id));

-- Policies for the 'recipe_ingredients' table
create policy select_recipe_ingredients on recipe_ingredients
for select
to authenticated
using (true);

create policy insert_recipe_ingredients on recipe_ingredients
for insert
to authenticated
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_ingredients.recipe_id and (select auth.uid()) = recipes.user_id));

create policy update_recipe_ingredients on recipe_ingredients
for update
to authenticated
using (exists (select 1 from recipes where recipes.recipe_id = recipe_ingredients.recipe_id and (select auth.uid()) = recipes.user_id))
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_ingredients.recipe_id and (select auth.uid()) = recipes.user_id));

create policy delete_recipe_ingredients on recipe_ingredients
for delete
to authenticated 
using (exists (select 1 from recipes where recipes.recipe_id = recipe_ingredients.recipe_id and (select auth.uid()) = recipes.user_id));

-- Policies for the 'recipe_tags' table
create policy select_recipe_tags on recipe_tags
for select
to authenticated
using (true);

create policy insert_recipe_tags on recipe_tags
for insert
to authenticated
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_tags.recipe_id and (select auth.uid()) = recipes.user_id));

create policy update_recipe_tags on recipe_tags
for update
to authenticated
using (exists (select 1 from recipes where recipes.recipe_id = recipe_tags.recipe_id and (select auth.uid()) = recipes.user_id))
with check (exists (select 1 from recipes where recipes.recipe_id = recipe_tags.recipe_id and (select auth.uid()) = recipes.user_id));

create policy delete_recipe_tags on recipe_tags
for delete
to authenticated 
using (exists (select 1 from recipes where recipes.recipe_id = recipe_tags.recipe_id and (select auth.uid()) = recipes.user_id));

-- Policies for the 'tags' table
create policy select_tags on tags
for select
to authenticated
using (true);

create policy insert_tags on tags
for insert
to authenticated
with check (true);

-- Policies for the 'ingredients' table
create policy select_ingredients on ingredients
for select
to authenticated
using (true);

create policy insert_ingredients on ingredients
for insert
to authenticated
with check (true);