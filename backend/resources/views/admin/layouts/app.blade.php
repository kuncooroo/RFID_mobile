<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') — Kutuku RFID</title>
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>
<body class="admin-body">
<aside class="sidebar">
    <div class="brand">
        <span class="brand-mark">K</span>
        <div>
            <strong>Kutuku Admin</strong>
            <small>{{ auth()->user()->role?->label() }}</small>
        </div>
    </div>

    <nav class="nav">
        <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">Dashboard</a>
        <a href="{{ route('admin.visitors.index') }}" class="{{ request()->routeIs('admin.visitors.*') ? 'active' : '' }}">Visitors</a>
        <a href="{{ route('admin.rfid.bind') }}" class="{{ request()->routeIs('admin.rfid.bind*') ? 'active' : '' }}">Bind RFID Card</a>
        <a href="{{ route('admin.rfid.scans') }}" class="{{ request()->routeIs('admin.rfid.scans') ? 'active' : '' }}">RFID Scan Log</a>
        <a href="{{ route('admin.gallery.index') }}" class="{{ request()->routeIs('admin.gallery.*') ? 'active' : '' }}">Photo Gallery</a>

        @if(auth()->user()?->isSuperadmin())
            <div class="nav-section">Superadmin</div>
            <a href="{{ route('admin.staff.index') }}" class="{{ request()->routeIs('admin.staff.*') ? 'active' : '' }}">Staff Accounts</a>
            <a href="{{ route('admin.analytics') }}" class="{{ request()->routeIs('admin.analytics') ? 'active' : '' }}">Analytics</a>
            <a href="{{ route('admin.activity.index') }}" class="{{ request()->routeIs('admin.activity.*') ? 'active' : '' }}">Activity Log</a>
        @endif
    </nav>

    <form method="POST" action="{{ route('admin.logout') }}" class="sidebar-logout">
        @csrf
        <button type="submit">Sign out</button>
    </form>
</aside>

<main class="content">
    <header class="topbar">
        <div>
            <h1>@yield('heading', 'Dashboard')</h1>
            @hasSection('subheading')
                <p class="muted">@yield('subheading')</p>
            @endif
        </div>
        <div class="topbar-user">{{ auth()->user()->name }}</div>
    </header>

    @if(session('success'))
        <div class="alert success">{{ session('success') }}</div>
    @endif

    @if($errors->any())
        <div class="alert danger">
            <ul>
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    @yield('content')
</main>
@stack('scripts')
</body>
</html>
