<?php

return [
    'checkin_points' => (int) env('KIOSK_CHECKIN_POINTS', 10),
    /** Points required to earn 1.00 currency of checkout discount. */
    'points_per_currency' => (int) env('KIOSK_POINTS_PER_CURRENCY', 100),
    'default_location_id' => env('KIOSK_LOCATION_ID') ? (int) env('KIOSK_LOCATION_ID') : null,
    /** Seconds between accepted RFID visits for the same card+location. */
    'scan_cooldown_seconds' => (int) env('KIOSK_SCAN_COOLDOWN_SECONDS', 60),
    /** Highest saldo an issued card can hold before identity is linked. */
    'anonymous_balance_cap' => (float) env('KIOSK_ANONYMOUS_BALANCE_CAP', 1000000),
    /** Highest saldo after the card is linked to an identity. */
    'registered_balance_cap' => (float) env('KIOSK_REGISTERED_BALANCE_CAP', 10000000),
];
