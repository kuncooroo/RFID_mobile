<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>Admin Login — Kutuku RFID</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>

<body class="login-page">

    <div class="login-card">

        <h1 style="text-align:center;">Admin Dashboard</h1>

        <p style="text-align:center;">
            Sign in with a staff account (admin / superadmin).
        </p>

        @if($errors->any())
        <div class="alert danger">
            <ul>
                @foreach($errors->all() as $error)
                <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.login.store') }}" class="stack">
            @csrf

            <label>
                Email

                <input
                    type="email"
                    name="email"
                    value="{{ old('email') }}"
                    required
                    autofocus>
            </label>

            <label>
                Password

                <div style="position:relative;">
                    <input
                        type="password"
                        name="password"
                        id="password"
                        required
                        style="padding-right:45px;">

                    <button
                        type="button"
                        onclick="togglePassword()"
                        id="passwordToggle"
                        aria-label="Show password"
                        style="
                position:absolute;
                right:10px;
                top:50%;
                transform:translateY(-50%);
                border:none;
                background:none;
                cursor:pointer;
                padding:4px;
                color:#6b7280;
            ">
                        <!-- Eye -->
                        <svg id="eyeOpen" width="20" height="20" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" />
                            <circle cx="12" cy="12" r="3" />
                        </svg>

                        <!-- Eye Off -->
                        <svg id="eyeClosed" width="20" height="20" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                            style="display:none;">
                            <path d="M3 3l18 18" />
                            <path d="M10.6 10.6a2 2 0 0 0 2.8 2.8" />
                            <path d="M9.9 4.2A10.8 10.8 0 0 1 12 4c6.5 0 10 8 10 8a18.5 18.5 0 0 1-3.1 4.4" />
                            <path d="M6.6 6.6C3.8 8.6 2 12 2 12s3.5 7 10 7a10.8 10.8 0 0 0 3.4-.5" />
                        </svg>
                    </button>
                </div>
            </label>

            <label style="display:flex;align-items:center;gap:8px;font-weight:500;">
                <input
                    type="checkbox"
                    name="remember"
                    value="1"
                    style="width:auto;">

                Remember me
            </label>

            <button class="btn" type="submit">
                Sign in
            </button>

        </form>

    </div>

    <script>
        function togglePassword() {
            const password = document.getElementById('password');
            const eyeOpen = document.getElementById('eyeOpen');
            const eyeClosed = document.getElementById('eyeClosed');
            const button = document.getElementById('passwordToggle');

            if (password.type === 'password') {
                password.type = 'text';

                eyeOpen.style.display = 'none';
                eyeClosed.style.display = 'block';

                button.setAttribute('aria-label', 'Hide password');
            } else {
                password.type = 'password';

                eyeOpen.style.display = 'block';
                eyeClosed.style.display = 'none';

                button.setAttribute('aria-label', 'Show password');
            }
        }
    </script>

</body>

</html>