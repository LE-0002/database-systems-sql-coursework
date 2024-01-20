-- __/\\\\\\\\\\\__/\\\\\_____/\\\__/\\\\\\\\\\\\\\\____/\\\\\_________/\\\\\\\\\_________/\\\\\\\________/\\\\\\\________/\\\\\\\________/\\\\\\\\\\________________/\\\\\\\\\_______/\\\\\\\\\_____        
--  _\/////\\\///__\/\\\\\\___\/\\\_\/\\\///////////___/\\\///\\\_____/\\\///////\\\_____/\\\/////\\\____/\\\/////\\\____/\\\/////\\\____/\\\///////\\\_____________/\\\\\\\\\\\\\___/\\\///////\\\___       
--   _____\/\\\_____\/\\\/\\\__\/\\\_\/\\\____________/\\\/__\///\\\__\///______\//\\\___/\\\____\//\\\__/\\\____\//\\\__/\\\____\//\\\__\///______/\\\_____________/\\\/////////\\\_\///______\//\\\__      
--    _____\/\\\_____\/\\\//\\\_\/\\\_\/\\\\\\\\\\\___/\\\______\//\\\___________/\\\/___\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\_________/\\\//_____________\/\\\_______\/\\\___________/\\\/___     
--     _____\/\\\_____\/\\\\//\\\\/\\\_\/\\\///////___\/\\\_______\/\\\________/\\\//_____\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\________\////\\\____________\/\\\\\\\\\\\\\\\________/\\\//_____    
--      _____\/\\\_____\/\\\_\//\\\/\\\_\/\\\__________\//\\\______/\\\______/\\\//________\/\\\_____\/\\\_\/\\\_____\/\\\_\/\\\_____\/\\\___________\//\\\___________\/\\\/////////\\\_____/\\\//________   
--       _____\/\\\_____\/\\\__\//\\\\\\_\/\\\___________\///\\\__/\\\______/\\\/___________\//\\\____/\\\__\//\\\____/\\\__\//\\\____/\\\___/\\\______/\\\____________\/\\\_______\/\\\___/\\\/___________  
--        __/\\\\\\\\\\\_\/\\\___\//\\\\\_\/\\\_____________\///\\\\\/______/\\\\\\\\\\\\\\\__\///\\\\\\\/____\///\\\\\\\/____\///\\\\\\\/___\///\\\\\\\\\/_____________\/\\\_______\/\\\__/\\\\\\\\\\\\\\\_ 
--         _\///////////__\///_____\/////__\///________________\/////_______\///////////////_____\///////________\///////________\///////_______\/////////_______________\///________\///__\///////////////__

-- Your Name: David Le
-- Your Student Number: 1352146
-- By submitting, you declare that this work was completed entirely by yourself.

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1
SELECT id AS videoID, title
FROM video
WHERE id not in 
((SELECT sourceVIDEOID FROM annotation) UNION
(SELECT destinationVIDEOID from annotation));


-- END Q1
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2
SELECT videoID, linkedUser AS username, ratingTime as ratingTimestamp
FROM rating
ORDER BY ratingTime DESC
LIMIT 1;



-- END Q2
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3
SELECT video.id as videoID, title
FROM video 
 INNER JOIN cocreator ON video.id = cocreator.videoID
WHERE viewCount > 1000000 
 AND id in 
(SELECT id FROM content_creator WHERE screenName = 'TaylorSwiftOfficial');


-- END Q3
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT id as videoID, title, linkedCount
FROM 
 video 
 NATURAL JOIN
  (SELECT destinationVideoID as id, COUNT(destinationVideoID) as linkedCount
    FROM annotation
    GROUP BY destinationVideoID
    ORDER BY linkedCount DESC
    LIMIT 1) AS linkedCountTable;

-- END Q4
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT video.ID as videoID, uploaded AS uploadDatetime, COUNT(rating) AS ratingCount
FROM video
 LEFT OUTER JOIN rating ON video.id = rating.videoID
 INNER JOIN video_hashtag ON video.id = video_hashtag.videoID
WHERE hashtagID IN (SELECT id FROM hashtag WHERE tag = '#memes')
GROUP BY video.ID
HAVING COUNT(rating) >= 3;


-- END Q5
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT DISTINCT username, realName, screenName
FROM (cocreator
 NATURAL JOIN
  (SELECT content_creator.id as creatorID, realName, screenName, username
  FROM content_creator INNER JOIN user ON user.id = content_creator.linkedUser
  WHERE reputation < 50)  AS controversial_creators_table)
WHERE creatorID 
 IN (SELECT creatorID
  FROM cocreator NATURAL JOIN
 (SELECT videoID, COUNT(*) as numRatings
 FROM rating
 GROUP BY videoID) AS numRatingsTable
 GROUP BY creatorID
HAVING SUM(numRatings) >= 6 && COUNT(videoID) >= 3);

-- END Q6
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT tag AS hashtag, commentCount
FROM
 (SELECT tag, count(comment) as commentCount
  FROM (video_hashtag INNER JOIN hashtag ON hashtag.id = video_hashtag.hashtagID
   NATURAL JOIN rating) 
  WHERE comment LIKE '%thank you%' OR comment LIKE '%well done%'
  GROUP BY tag) AS totalValues
WHERE commentCount = 
 (SELECT max(commentCount) FROM
  (SELECT tag, count(comment) AS commentCount
   FROM (video_hashtag INNER JOIN hashtag ON hashtag.id = video_hashtag.hashtagID
    NATURAL JOIN rating)
   WHERE comment LIKE '%thank you%' OR comment LIKE '%well done%'
   GROUP BY tag) 
 AS totalValues);

-- END Q7
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT tag AS hashtag, totalAnnotationsAsDestination, totalDuration
FROM 
 (SELECT hashtagID, COUNT(destinationVideoID) AS totalAnnotationsAsDestination, sum(duration) AS totalDuration
  FROM video_hashtag 
   INNER JOIN annotation ON annotation.destinationVideoID = video_hashtag.videoID
  GROUP BY hashtagID
  ORDER BY totalAnnotationsAsDestination DESC) AS totalValuesTable
 NATURAL JOIN
  (SELECT DISTINCT COUNT(destinationVideoID) as totalAnnotationsAsDestination
   FROM video_hashtag 
    INNER JOIN annotation ON annotation.destinationVideoID = video_hashtag.videoID
   GROUP BY hashtagID
   ORDER BY totalAnnotationsAsDestination DESC
   LIMIT 3) AS top_3_numAnnotations
 INNER JOIN hashtag ON totalValuesTable.hashtagID = hashtag.id;

-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT DISTINCT realName, screenName
FROM cocreator
	INNER JOIN cocreator AS cocreator2 ON cocreator.videoID = cocreator2.videoID
    INNER JOIN content_creator_hashtag AS cch ON cocreator.creatorID = cch.creatorID
    INNER JOIN content_creator_hashtag AS cch2 ON cocreator2.creatorID = cch2.creatorID
    INNER JOIN content_creator ON cocreator.creatorID = content_creator.id
 WHERE cch.hashtagID IN 
  (SELECT id FROM hashtag WHERE tag = '#memes')
  AND cch2.hashtagID IN 
   (SELECT id FROM hashtag WHERE tag = '#technology')
  AND cocreator.creatorID <> cocreator2.creatorID;

-- END Q9
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT realName, screenName
FROM cocreator
  LEFT OUTER JOIN cocreator AS cocreator2 ON cocreator.videoID = cocreator2.videoID
  INNER JOIN video ON cocreator.videoID = video.ID 
  INNER JOIN content_creator ON cocreator.creatorID = content_creator.id
WHERE cocreator.creatorID <> cocreator2.creatorID
 AND cocreator2.creatorID IN 
  (SELECT id FROM content_creator WHERE screenName = 'INFO20003Memes')
GROUP BY content_creator.id
HAVING COUNT(CASE WHEN uploaded >= '2023-01-01' THEN true END) >= 1 AND
 COUNT(CASE WHEN uploaded < '2023-01-01' THEN true END) = 0;



-- END Q10
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- END OF ASSIGNMENT Do not write below this line