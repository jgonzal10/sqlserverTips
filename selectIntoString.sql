-- CONCATENATE MULTIPLE IDS OF A SELECT RESULT INTO ONE RESULT

SELECT idUser
             FROM Users em,
                  [dbSchool].[dbo].[ExamTaken] et
             WHERE em.idEvent = et.idEvent
              
              AND et.idAccount = em.idAccount for json path