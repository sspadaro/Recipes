-- Tests on the RLS policies for Recipe Organizer.

-- TESTS FOR 'RECIPES' TABLE ---------------------------------------------------------------------
-- Test 1.1: Alice tries to add a recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into public.recipes (user_id, name, servings) VALUES ('bfa0132b-97fc-4906-8214-847328e9e3ad', 'bread', 4);

commit;

-- Test 1.2: Bob tries to view existing recipes
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

select * from recipes;

commit;

-- Test 1.3: Bob tries to update Alice's recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update recipes
set name = 'sourdough'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' returning *;

commit;

-- Test 1.4: Alice tries to update her own recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update recipes
set name = 'sourdough'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' returning *;

commit;

-- Test 1.5: Bob tries to delete Alice's recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from public.recipes
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' returning *;

commit;

-- Test 1.6: Bob inserts a recipe claiming to be Alice
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

insert into public.recipes (user_id, name, servings) VALUES ('bfa0132b-97fc-4906-8214-847328e9e3ad', 'pizza', 2);

commit;

-- TESTS FOR RECIPE_STEPS ------------------------------------------------------------------------
-- Test 2.1: Alice inserts a step on her own recipe_id
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into public.recipe_steps (recipe_id, step_number, instruction) values ('15b57fa7-c9df-4f35-a662-a4381481ed0d', 1, 'Preheat the oven.') returning *;

commit;

-- Test 2.2: Bob inserts a step on Alice's recipe_id
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

insert into public.recipe_steps (recipe_id, step_number, instruction) VALUES ('15b57fa7-c9df-4f35-a662-a4381481ed0d', 2, 'Gather all ingredients.') returning *;

commit;

-- Test 2.3: Bob updates Alice's step
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update recipe_steps
set instruction = 'Preheat the oven to 400 degrees.'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and step_number = 1 returning *;

commit;

-- Test 2.4: Bob deletes Alice's step
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from recipe_steps
where recipe_steps.recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and recipe_steps.step_number = 1 returning *;

commit;

-- Test 2.5: Alice updates her own step
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update recipe_steps
set instruction = 'Preheat the oven to 360 degrees.'
where recipe_steps.recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and recipe_steps.step_number = 1 returning *;

commit;

-- Test 2.6: Alice deletes her own step
--First she will add a new step.
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into public.recipe_steps (recipe_id, step_number, instruction) values ('15b57fa7-c9df-4f35-a662-a4381481ed0d', 2, 'Mix together all ingredients.') returning *;

commit;
-- Now she will delete it
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

delete from recipe_steps
where recipe_steps.recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and recipe_steps.step_number = 2 returning *;

commit;

-- Test 2.7: Alice tries to change her recipe step to having Bob's recipe's ID
-- Bob creates a recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

insert into public.recipes (user_id, name, servings) values ('128172ac-3ce7-4395-b732-650fa9730774', 'Meatballs', 4) returning *;

commit;
-- Alice changes her step to have the recipe id of Bob's new recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update recipe_steps
set recipe_id = '6d246f04-03ac-462b-a836-fecf707ec7e4'
where recipe_steps.recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and recipe_steps.step_number = 1 returning *;

commit;

-- TESTS FOR RECIPE_INGREDIENTS ----------------------------------------------------------------------
--First insert an ingredient and a tag as default admin role
begin;

insert into ingredients (name) values ('flour');
insert into tags (name) values ('healthy');

commit;

-- Test 3.1: Alice inserts a recipe_ingredients row on her recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into public.recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES ('15b57fa7-c9df-4f35-a662-a4381481ed0d', 'f6a63072-081f-4f0f-8c6b-30ca687d1942', 1, 'cup') returning *;

commit;

-- Test 3.2: Bob inserts a recipe_ingredients row on Alice's recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

insert into public.recipe_ingredients (recipe_id, ingredient_id, quantity, unit) VALUES ('15b57fa7-c9df-4f35-a662-a4381481ed0d', 'f6a63072-081f-4f0f-8c6b-30ca687d1942', 1, 'cup');

commit;

-- Test 3.3: Bob updates Alice's row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update recipe_ingredients
set quantity = 2, unit = 'cups'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and ingredient_id = 'f6a63072-081f-4f0f-8c6b-30ca687d1942' returning *;

commit;

-- Test 3.4: Bob deletes Alice's row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from recipe_ingredients
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and ingredient_id = 'f6a63072-081f-4f0f-8c6b-30ca687d1942' returning *;

commit;

-- Test 3.5: Alice updates her own row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update recipe_ingredients
set quantity = 3, unit = 'cups'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and ingredient_id = 'f6a63072-081f-4f0f-8c6b-30ca687d1942' returning *;

commit;

-- Test 3.6 Alice deletes her own row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

delete from recipe_ingredients
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and ingredient_id = 'f6a63072-081f-4f0f-8c6b-30ca687d1942' returning *;

commit;

-- TESTS FOR RECIPE_TAGS ------------------------------------------------------------------------
-- Test 4.1: Alice inserts a recipe_tags row on her recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into public.recipe_tags (recipe_id, tag_id) VALUES ('15b57fa7-c9df-4f35-a662-a4381481ed0d', '52101d4b-5e4e-4d47-b43d-464186106e7a') returning *;

commit;

-- Test 4.2: Bob inserts a recipe_tags row on Alice's recipe
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

insert into public.recipe_tags (recipe_id, tag_id) VALUES ('15b57fa7-c9df-4f35-a662-a4381481ed0d', '52101d4b-5e4e-4d47-b43d-464186106e7a') returning *;

commit;

-- Test 4.3: Bob updates Alice's row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update recipe_tags
set recipe_id = '6d246f04-03ac-462b-a836-fecf707ec7e4'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and tag_id = '52101d4b-5e4e-4d47-b43d-464186106e7a' returning *;

commit;

-- Test 4.4: Bob deletes Alice's row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from recipe_tags
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and tag_id = '52101d4b-5e4e-4d47-b43d-464186106e7a' returning *;

commit;

-- Test 4.5: Alice updates her own row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update recipe_tags
set recipe_id = '6d246f04-03ac-462b-a836-fecf707ec7e4'
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and tag_id = '52101d4b-5e4e-4d47-b43d-464186106e7a' returning *;

commit;

-- Test 4.6 Alice deletes her own row
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

delete from recipe_tags
where recipe_id = '15b57fa7-c9df-4f35-a662-a4381481ed0d' and tag_id = '52101d4b-5e4e-4d47-b43d-464186106e7a' returning *;

commit;

-- TESTS FOR TAGS --------------------------------------------------------------------------
-- Test 5.1: Alice inserts a new tag
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into tags (name) values ('Breakfast') returning *;

commit;

-- Test 5.2: Bob reads the tags
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

select * from tags;

commit;

-- Test 5.3: Bob updates the tag
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update tags
set name = 'Lunch'
where tag_id = '646ca3fc-3366-4d4b-9407-34ea99743385' returning *;

commit;

-- Test 5.4: Bob deletes the tag
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from tags
where tag_id = '646ca3fc-3366-4d4b-9407-34ea99743385' returning *;

commit;

-- Test 5.5: Alice updates the tag
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update tags
set name = 'Lunch'
where tag_id = '646ca3fc-3366-4d4b-9407-34ea99743385' returning *;

commit;

-- Test 5.6: Alice deletes the tag
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

delete from tags
where tag_id = '646ca3fc-3366-4d4b-9407-34ea99743385' returning *;

commit;

-- TESTS FOR INGREDIENTS -------------------------------------------------------------------------
-- Test 6.1: Alice inserts a new ingredient
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

insert into ingredients (name) values ('Water') returning *;

commit;

-- Test 6.2: Bob reads the ingredients
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

select * from ingredients;

commit;

-- Test 6.3: Bob updates the ingredient
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

update ingredients
set name = 'water'
where ingredient_id = 'fa490c22-c71a-437e-9751-977839fc10f9' returning *;

commit;

-- Test 6.4: Bob deletes the ingredient
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"128172ac-3ce7-4395-b732-650fa9730774","role":"authenticated"}', true);

delete from ingredients
where ingredient_id = 'fa490c22-c71a-437e-9751-977839fc10f9' returning *;

commit;

-- Test 6.5: Alice updates the ingredient
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

update ingredients
set name = 'water'
where ingredient_id = 'fa490c22-c71a-437e-9751-977839fc10f9' returning *;

commit;

-- Test 6.6: Alice deletes the ingredient
begin;
set local role authenticated;
select set_config('request.jwt.claims', '{"sub":"bfa0132b-97fc-4906-8214-847328e9e3ad","role":"authenticated"}', true);

delete from ingredients
where ingredient_id = 'fa490c22-c71a-437e-9751-977839fc10f9' returning *;

commit;
