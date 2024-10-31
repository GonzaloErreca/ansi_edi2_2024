<?php

function handle_request()
{
    $list = [];

    $appointmentsFirstHour = 8;
    $appointmentsPerDay = 8;
    $daysWithAppointments = 2;

    $db = new SQLite3('database.sqlite');

    $veterinariesQuantity = $db->querySingle('SELECT count(id) FROM veterinario');

    if ($veterinariesQuantity) {
        $tz = new DateTimeZone('America/Buenos_Aires');
        $now = new DateTime('now', $tz);

        $allAppointments = [];

        for ($i = 1; $i <= $daysWithAppointments; ++$i) {
            for ($j = 0; $j < $appointmentsPerDay; ++$j) {
                // https://www.php.net/manual/en/datetime.format.php
                $format = 'Y n d G i s';

                $year = $now->format('Y');
                $month = $now->format('n');
                $day = $now->format('j') + $i;
                $hour = $appointmentsFirstHour + $j;

                $appointment = DateTime::createFromFormat(
                    $format,
                    "{$year} {$month} {$day} {$hour} 00 00",
                    $tz
                );

                $appointment = $appointment->format('Ymd\THis').'ART';

                $allAppointments[$appointment] = 0;
            }
        }

        $takenAppointments = $db->query('SELECT turno FROM turno');

        while ($row = $takenAppointments->fetchArray(SQLITE3_ASSOC)) {
            if (isset($allAppointments[$row['turno']])) {
                ++$allAppointments[$row['turno']];
            }
        }

        foreach ($allAppointments as $key => $value) {
            if ($value < $veterinariesQuantity) {
                $list[] = $key;
            }
        }
    }

    $db->close();

    echo json_encode($list);
}
