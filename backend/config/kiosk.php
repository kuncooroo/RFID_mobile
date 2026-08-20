<?php

return [
    'checkin_points' => (int) env('KIOSK_CHECKIN_POINTS', 10),
    'default_location_id' => env('KIOSK_LOCATION_ID') ? (int) env('KIOSK_LOCATION_ID') : null,
    /** Seconds between accepted RFID visits for the same user+location. */
    'scan_cooldown_seconds' => (int) env('KIOSK_SCAN_COOLDOWN_SECONDS', 60),
];
