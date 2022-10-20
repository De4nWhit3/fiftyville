-- Keep a log of any SQL queries you execute as you solve the mystery.
-- Check all cases logged for July 28, 2021 at Humphrey Street, (added description like duck for terminal space)
SELECT id, description FROM crime_scene_reports where day = 28 AND month = 7 AND year = 2021 AND street LIKE 'Humphrey Street' AND description LIKE '%duck%';
--  295, Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery.
--  Interviews were conducted today with three witnesses who were present at the time –
--  each of their interview transcripts mentions the bakery.
--  Check format of interviews table
-- Narrow interviews down to ones that mention bakery
SELECT id, name, transcript FROM interviews WHERE day = 28 AND month = 7 AND year = 2021 AND transcript LIKE '%bakery%';
-- 161 Ruth
--  Sometime within ten minutes (incident time: 10:15am) of the theft, I saw the thief get into a car in the bakery
--  parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for
--  cars that left the parking lot in that time frame.
-- 162 Eugene
--  I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery,
--  I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
-- 163 Raymond
--  As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard
--  the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the
--  person on the other end of the phone to purchase the flight ticket.

-- CHECK WHO LEFT THE BAKERY FROM 10:15 TO 10:25, CHECK THE LICENSE PLATES, CHECK WHO HAS THAT LICENSE PLATE, CHECK THEIR
-- PHONE NUMBER AGAINST THE NUMBERS WHO MADE THE CALL
-- SELECT first_name AS fn
--   FROM staff AS s1
--   JOIN students AS s2
--     ON s2.mentor_id = s1.staff_num;

-- Get details of someone with the numberplate + phone number + bank transaction information
-- SELECT *
--   FROM bakery_security_logs AS bsl
--   JOIN people AS p
--     ON bsl.license_plate = p.license_plate
--  WHERE bsl.license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2021 AND hour = 10 AND minute BETWEEN 15 AND 25)
--    AND p.phone_number IN (SELECT caller FROM phone_calls WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60)
--    AND p.id IN (SELECT ba.person_id
--                  FROM atm_transactions AS atmt
--                  JOIN bank_accounts as ba
--                    ON atmt.account_number = ba.account_number
--                 WHERE day = 28 AND month = 7 AND year = 2021 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw')
--    AND p.passport_number IN (SELECT passport_number
--                               FROM passengers AS psgs
--                               JOIN flights AS f
--                                 ON psgs.flight_id = f.id
--                             WHERE f.day = 29 AND f.month = 7 AND f.year = 2021
--                               AND f.origin_airport_id = (SELECT id FROM airports WHERE full_name like 'Fiftyville%'));

-- Get suspects to investiagte
SELECT *
  FROM people
 WHERE (phone_number IN (SELECT caller FROM phone_calls WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60)
    OR phone_number IN (SELECT receiver FROM phone_calls WHERE day = 28 AND month = 7 AND year = 2021 AND duration < 60))
   AND license_plate IN (SELECT license_plate FROM bakery_security_logs WHERE day = 28 AND month = 7 AND year = 2021 AND hour = 10 AND minute BETWEEN 15 AND 25)
   AND id IN (SELECT ba.person_id
                FROM atm_transactions AS atmt
                JOIN bank_accounts as ba
                  ON atmt.account_number = ba.account_number
               WHERE day = 28 AND month = 7 AND year = 2021 AND atm_location = 'Leggett Street' AND transaction_type = 'withdraw');
-- |   id   | name  |  phone_number  | passport_number | license_plate |
-- | 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
-- | 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
SELECT *
FROM phone_calls
WHERE id = 514354;


OBJECTIVE OF QUERY:
GET THIEF NAME
  - check licence_plate, phone_number, transaction_details
GET ACCOMPLICE NAME (WHO DID SHE CALL)
  - check who the receiver was fromt he phone call
GET DESTINATION WHERE SHE IS FLYING TO
  - use passport number and check destination from fiftyville

-- join a lot of tables to make the query easier?





-----------------------------------------------------------------------
-- Find the 2 persons responsible
-----------------------------------------------------------------------
-- STEP 1: Pull up the case reports, incident @ 10:15am
SELECT id, description
  FROM crime_scene_reports
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND street LIKE 'Humphrey Street'
   AND description LIKE '%duck%';

-- STEP 2: Check the witness testimonies that mention bakery
SELECT id, name, transcript
  FROM interviews
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND transcript LIKE '%bakery%';

-- STEP 3: Follow up on clues provided by witnesses
-- | 161 | Ruth    |
--     Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away.
--     If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot
--     in that time frame.
SELECT id, license_plate, activity
  FROM bakery_security_logs
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND hour = 10
   AND minute BETWEEN 15 AND 25;

-- | 162 | Eugene  |
--    I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's
--    bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
SELECT ba.person_id
  FROM atm_transactions AS atmt
  JOIN bank_accounts as ba
    ON atmt.account_number = ba.account_number
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND atm_location = 'Leggett Street'
   AND transaction_type = 'withdraw';

-- | 163 | Raymond |
--    As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call,
--    I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief
--    then asked the person on the other end of the phone to purchase the flight ticket. |
SELECT id, caller, receiver -- this is phone numbers
  FROM phone_calls
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND duration < 60;

-- STEP 4: Check who in the people table had the given phone number, license plate
SELECT *
  FROM people
 WHERE phone_number IN (SELECT caller -- this is phone numbers
                         FROM phone_calls
                        WHERE day = 28
                          AND month = 7
                          AND year = 2021
                          AND duration < 60)
   AND license_plate IN (SELECT license_plate
                          FROM bakery_security_logs
                         WHERE day = 28
                           AND month = 7
                           AND year = 2021
                           AND hour = 10
                           AND minute BETWEEN 15 AND 25)
   AND id IN (SELECT ba.person_id
                FROM atm_transactions AS atmt
                JOIN bank_accounts as ba
                  ON atmt.account_number = ba.account_number
               WHERE day = 28
                 AND month = 7
                 AND year = 2021
                 AND atm_location = 'Leggett Street'
                 AND transaction_type = 'withdraw');


-- STEP 5: Check which flight took off first on the 29th
-- Going from
SELECT air.id, air.full_name
  FROM flights AS fly
  JOIN airports AS air
    ON fly.origin_airport_id = air.id;

-- Going to
SELECT air.id, air.full_name
  FROM flights AS fly
  JOIN airports AS air
    ON fly.destination_airport_id = air.id;

-- Check first flight on the 29th
  SELECT *
    FROM flights
   WHERE day = 29
     AND month = 7
     AND year = 2021
ORDER BY hour ASC
   LIMIT 1;

-- STEP 6: Putting it all together (the culprit)
SELECT distinct(ppl.name), pass.flight_id, pass.seat
  FROM people AS ppl
  JOIN passengers AS pass
    ON ppl.passport_number = pass.passport_number
 WHERE pass.flight_id = (SELECT id
                           FROM flights
                          WHERE day = 29
                            AND month = 7
                            AND year = 2021
                       ORDER BY hour ASC
                          LIMIT 1)
  AND ppl.license_plate IN (SELECT license_plate
                          FROM bakery_security_logs
                         WHERE day = 28
                           AND month = 7
                           AND year = 2021
                           AND hour = 10
                           AND minute BETWEEN 15 AND 25)
  AND ppl.phone_number IN (SELECT caller -- this is phone numbers
                             FROM phone_calls
                            WHERE day = 28
                              AND month = 7
                              AND year = 2021
                              AND duration < 60)
  AND ppl.id IN (SELECT ba.person_id
                FROM atm_transactions AS atmt
                JOIN bank_accounts as ba
                  ON atmt.account_number = ba.account_number
               WHERE day = 28
                 AND month = 7
                 AND year = 2021
                 AND atm_location = 'Leggett Street'
                 AND transaction_type = 'withdraw');

-- STEP 7: Check destination
SELECT full_name
  FROM airports
 WHERE id = (SELECT destination_airport_id
               FROM flights
              WHERE day = 29
                AND month = 7
                AND year = 2021
           ORDER BY hour ASC
              LIMIT 1);

-- STEP 8: Who was the accomplice
SELECT ppl.name
  FROM people AS ppl
  JOIN phone_calls AS phone
    ON ppl.phone_number = phone.receiver
 WHERE day = 28
   AND month = 7
   AND year = 2021
   AND duration < 60
   AND caller = (SELECT distinct(ppl.phone_number)
                  FROM people AS ppl
                  JOIN passengers AS pass
                    ON ppl.passport_number = pass.passport_number
                WHERE pass.flight_id = (SELECT id
                                          FROM flights
                                          WHERE day = 29
                                            AND month = 7
                                            AND year = 2021
                                      ORDER BY hour ASC
                                          LIMIT 1)
                  AND ppl.license_plate IN (SELECT license_plate
                                          FROM bakery_security_logs
                                        WHERE day = 28
                                          AND month = 7
                                          AND year = 2021
                                          AND hour = 10
                                          AND minute BETWEEN 15 AND 25)
                  AND ppl.phone_number IN (SELECT caller -- this is phone numbers
                                            FROM phone_calls
                                            WHERE day = 28
                                              AND month = 7
                                              AND year = 2021
                                              AND duration < 60)
                  AND ppl.id IN (SELECT ba.person_id
                                FROM atm_transactions AS atmt
                                JOIN bank_accounts as ba
                                  ON atmt.account_number = ba.account_number
                              WHERE day = 28
                                AND month = 7
                                AND year = 2021
                                AND atm_location = 'Leggett Street'
                                AND transaction_type = 'withdraw'));

-- STEP 9: Update the destination query (it seems erroneous)
SELECT full_name
  FROM airports
 WHERE id = (SELECT destination_airport_id
                FROM flights
              WHERE id = (SELECT distinct(pass.flight_id)
                            FROM people AS ppl
                            JOIN passengers AS pass
                              ON ppl.passport_number = pass.passport_number
                          WHERE pass.flight_id = (SELECT id
                                                    FROM flights
                                                    WHERE day = 29
                                                      AND month = 7
                                                      AND year = 2021
                                                ORDER BY hour ASC
                                                    LIMIT 1)
                            AND ppl.license_plate IN (SELECT license_plate
                                                    FROM bakery_security_logs
                                                  WHERE day = 28
                                                    AND month = 7
                                                    AND year = 2021
                                                    AND hour = 10
                                                    AND minute BETWEEN 15 AND 25)
                            AND ppl.phone_number IN (SELECT caller -- this is phone numbers
                                                      FROM phone_calls
                                                      WHERE day = 28
                                                        AND month = 7
                                                        AND year = 2021
                                                        AND duration < 60)
                            AND ppl.id IN (SELECT ba.person_id
                                          FROM atm_transactions AS atmt
                                          JOIN bank_accounts as ba
                                            ON atmt.account_number = ba.account_number
                                        WHERE day = 28
                                          AND month = 7
                                          AND year = 2021
                                          AND atm_location = 'Leggett Street'
                                          AND transaction_type = 'withdraw')));
