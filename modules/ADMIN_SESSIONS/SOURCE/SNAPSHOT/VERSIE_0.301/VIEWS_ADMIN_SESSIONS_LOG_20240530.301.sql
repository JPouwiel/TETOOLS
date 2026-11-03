CREATE OR REPLACE VIEW tetools.admin_sessions_60_min AS ( 
  SELECT * 
    FROM TETOOLS.ADMIN_SESSIONS_LOG 
	 WHERE LOG_DATE > systimestamp - (60/1440));

CREATE OR REPLACE VIEW tetools.admin_sessions_user AS 
  SELECT invoking_username,
         target_username,
         COUNT(invoking_username) number_requests_per_user,
         COUNT(CASE WHEN termntn_request_status = 'O' THEN termntn_request_status END) AS O,
         COUNT(CASE WHEN termntn_request_status = 'C' THEN termntn_request_status END) AS C,
         COUNT(CASE WHEN termntn_request_status = 'K' THEN termntn_request_status END) AS K,
         COUNT(CASE WHEN termntn_request_status = 'D' THEN termntn_request_status END) AS D,
         COUNT(CASE WHEN termntn_request_status = 'R' THEN termntn_request_status END) AS R,
         COUNT(CASE WHEN termntn_request_status = 'X' THEN termntn_request_status END) AS X,
         COUNT(CASE WHEN termntn_request_status = 'E' THEN termntn_request_status END) AS E,
         COUNT(CASE WHEN termntn_request_status = 'T' THEN termntn_request_status END) AS T,
         COUNT(CASE WHEN termntn_request_status = 'G' THEN termntn_request_status END) AS G,
         MIN(log_date) AS lower_date,
         MAX(log_date) AS upper_date
    FROM admin_sessions_log
GROUP BY invoking_username, target_username
ORDER BY number_requests_per_user DESC, invoking_username, target_username, upper_date;
