/*
Data Exploration
Skills used: CTE, JOIN, GROUP BY, HAVING, ROW_NUMBER() OVER, PARTITION BY, ORDER BY, LIMIT, Aggregate Functions (SUM, COUNT, ROUND)
*/


-- Looking at the top five assignments based on total value of donations, categorized by donor type.highest_donation_assignments

WITH donation_details AS(
	SELECT
		d1.assignment_id,
	    ROUND(SUM(d1.amount),2) AS rounded_total_donation_amount,
		d2.donor_type
	FROM donations d1
	JOIN donors d2 USING(donor_id)
	GROUP BY d1.assignment_id, d2.donor_type
)
SELECT a.assignment_name, a.region, dd.rounded_total_donation_amount, dd.donor_type
FROM assignments a
JOIN donation_details dd USING(assignment_id)
ORDER BY dd.rounded_total_donation_amount DESC
LIMIT 5;


-- Identify the assignment with the highest impact score in each region, ensuring that each listed assignment has received at least one donation.

WITH d_count AS(
	SELECT assignment_id, COUNT(*) AS num_total_donations
	FROM donations
	GROUP BY assignment_id
	HAVING COUNT(*) >= 1
),
ranked_a AS(
	SELECT
		a.assignment_name,
		a.region,
		a.impact_score,
		d_count.num_total_donations,
		ROW_NUMBER() OVER(PARTITION BY a.region ORDER BY a.impact_score DESC) AS rank
	FROM assignments a
	JOIN d_count USING(assignment_id)
	WHERE d_count.num_total_donations > 0
)
SELECT assignment_name, region, impact_score, num_total_donations
FROM ranked_a
WHERE rank = 1
ORDER BY region;