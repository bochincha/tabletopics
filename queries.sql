SELECT
 o.opt,
 o.tag,
   CASE
      WHEN code <= 2 THEN code
      WHEN code = 3 THEN 'invalid'
      WHEN code = 4 THEN 'n/a'
      ELSE 'Unknown'
   END AS code,
   count(code) AS freq
 FROM dialog d INNER JOIN opinion o USING (dialog_id) WHERE speaker_id!="F" 
 GROUP BY opt, tag, code
 HAVING freq BETWEEN -2 AND 2
 ORDER BY opt, tag, code, freq
 INTO OUTFILE '/tmp/tablegroup_noF2.csv'
 FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
