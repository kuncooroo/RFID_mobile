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
    <h1>Admin Dashboard</h1>
    <p>Sign in with an admin or superadmin account.</p>

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
            <input type="email" name="email" value="{{ old('email') }}" required autofocus>
        </label>
        <label>
            Password
            <input type="password" name="password" required>
        </label>
        <label style="display:flex;align-items:center;gap:8px;font-weight:500;">
            <input type="checkbox" name="remember" value="1" style="width:auto;">
            Remember me
        </label>
        <button class="btn" type="submit">Sign in</button>
    </form>
</div>
</body>
</html>
