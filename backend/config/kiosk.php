<?php

return [
    'checkin_points' => (int) env('KIOSK_CHECKIN_POINTS', 10),
    'default_location_id' => env('KIOSK_LOCATION_ID') ? (int) env('KIOSK_LOCATION_ID') : null,
];
