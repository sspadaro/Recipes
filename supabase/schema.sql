-- Initial tables for Recipe Organizer.
-- Already applied to the live database.

CREATE TABLE recipes (
  recipe_id UUID default gen_random_uuid() primary key,
  user_id UUID not null references auth.users(id) on delete cascade,
  name varchar(100) not null,
  cooking_time_minutes int check (cooking_time_minutes > 0),
  servings int not null check (servings > 0),
  description varchar(500),
  created_at timestamptz default current_timestamp not null
);

CREATE TABLE ingredients (
  ingredient_id UUID default gen_random_uuid() primary key,
  name varchar(100) unique not null
);

CREATE TABLE recipe_ingredients (
  recipe_ingredient_id UUID default gen_random_uuid() primary key,
  recipe_id UUID not null references recipes(recipe_id) on delete cascade,
  ingredient_id UUID not null references ingredients(ingredient_id) on delete restrict,
  quantity decimal(10,2),
  unit varchar(50),
  quantity_note text
);

CREATE TABLE recipe_steps(
  recipe_id UUID references recipes(recipe_id) on delete cascade,
  step_number int check (step_number > 0),
  instruction text not null,
  primary key (recipe_id, step_number)
);

CREATE TABLE tags(
  tag_id UUID default gen_random_uuid() primary key,
  name varchar(50) unique not null
);

CREATE TABLE recipe_tags(
  recipe_id UUID references recipes(recipe_id) on delete cascade,
  tag_id UUID references tags(tag_id) on delete cascade,
  primary key (recipe_id, tag_id)
);