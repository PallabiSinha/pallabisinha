#who is the senior most employee based on job title?

select levels, employee_id from employee
order by levels desc
limit 1;

#which country have the most invoices
select count(total), billing_country from invoice
group by billing_country
order by count(total) desc;

#what are top 3 values of total invoices
select total from invoice
order by total desc limit 3;

#Which city has the best customers? We would like to throw a promotional Music 
#Festival in the city we made the most money. Write a query that returns one city that
#has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

select sum(total), invoice.billing_city from invoice
group by invoice.billing_city
order by sum(total) desc;

#Who is the best customer? The customer who has spent the most money will be
#declared the best customer. Write a query that returns the person who has spent the most money

SELECT 
       customer.customer_id, SUM(invoice.total) AS most
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY most DESC
LIMIT 1;

#Write query to return the email, first name, last name, & Genre of all Rock Music
#listeners. Return your list ordered alphabetically by email starting with A

select customer.first_name, customer.last_name, customer.email, genre.name
from track
join genre on track.genre_id = genre.genre_id
join invoice_line on  invoice_line.track_id = track.track_id
join invoice on invoice_line.invoice_id= invoice.invoice_id
join customer on customer.customer_id= invoice.customer_id
order by customer.email asc;

#Let's invite the artists who have written the most rock music in our dataset. 
#Write a query that returns the Artist name and total track count of the top 10 rock bands 

select artist.name,  artist.artist_id, count(artist.artist_id) as total_song
from artist join album2 
on album2.artist_id = artist.artist_id
join track on track.album_id= album2.album_id
join genre on genre.genre_id= track.genre_id
where genre.name like 'Rock'
group by artist.name, artist.artist_id
order by total_song desc limit 10;


#Return all the track names that have a song length longer than the average song length. 
#Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first 
select track.name, track.milliseconds
from track 
where track.milliseconds>(select avg(track.milliseconds) from track)
order by track.milliseconds desc;

#Find how much amount spent by each customer on artists? Write a query to return 
#customer name, artist name and total spent 

WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album2 ON album2.album_id = track.album_id
	JOIN artist ON artist.artist_id = album2.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album2 alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


#Write a query that determines the customer that has spent the most on music for each country. 
#Write a query that returns the country along with the top customer and how much they spent. 
#For countries where the top amount spent is shared, provide all customers who spent this amount.

    WITH RECURSIVE 
    customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;
