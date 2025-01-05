-- 1. Count the number of Movies vs TV shows

select type, count(type) from netflix 
group by type;


-- 2. Find the most common rating for movies and Tv shows

select type, rating from
(select 
	type, rating,
count(*),
rank() over(partition by type order by count(*) desc) as ranking
 from netflix
 group by type, rating
 --order by 1,3 desc
) as t1
where ranking = 1;


-- 3. List all the movies released in a specific year (e.g., 2020)
select * from netflix
where type = 'Movie'
and
release_year = 2020;


-- 4. Find the top 5 countries with most content on Netflix

select 
unnest(string_to_array(country, ',')) as new_contry,
count(*)  as total_content
from netflix
group by 1 order by 2 desc limit 5;



-- 5. Identify the longest Movie?
select * from netflix
where type = 'Movie' 
and 
duration = (select max(duration) from netflix);


-- 6. Find content added in the last 5 year

select * from netflix
where to_date(date_added, 'Month DD YYYY') >= current_date - interval '5 years'


--use to_date function to convert data into date formate 
  to_date(date_added, 'Month DD YYYY')
  
-- used this function to show last date of 5 years ago
select current_date - interval '5 years'

select * from netflix;



-- 7. Find all the Movies/Tv shows by director 'Rajiv Chilaka'


select * from netflix
where director ilike  '%Rajiv Chilaka%';


-- 8. List all Tv Shows with more than 5 seasons. 

select *  from netflix
where type = 'TV Show' and
split_part(duration, ' ', 1)::numeric > 5;


-- 9. Count the number of content items in each genra


select unnest(string_to_array(listed_in,',')) as Genra, count(*) as total_list from 
netflix
group by 1;


-- 10. Find each year and the average numbers of content release in India on netflix.
--Return top 5 year with hightest average content release

select 
extract(year from TO_DATE(date_added, 'month dd yyyy' )) as year,
count(*),
round(count(*)::numeric/(select count(*)from netflix where country = 'India')::numeric*100 ,2) as avg
from netflix
where country = 'India'
group by 1 order by avg desc limit 5;


-- 11. List all movies that are documentries

select * from netflix
where  listed_in ilike '%documentaries%';


-- 12. Find all content without a director

select * from netflix 
where director is null


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years. 

select * from netflix
where 
	casts ilike '%salman khan%' 
	and
	release_year > extract(year from current_date) - 10;
	
	
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.


select unnest(string_to_array(casts,',')) as actor, count(*)
from netflix
where country ilike '%india'
group by 1
order by 2 desc 
limit 10


-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field.
-- Label content containing those keywords as 'Bed' and all other content as 'Good'. 
--Count how many times fall into each category.


with new_table
as
(
select *,
	case
	when 
		description ilike '%kill%' or
		description ilike '%violence%' then 'Bed content'
		else 'Good Content'
	end category
from netflix
)
select 
	category, 
	count(*) as total_content
from new_table
group by 1;

