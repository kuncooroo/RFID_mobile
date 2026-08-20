<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') — Kutuku RFID</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>
<body class="admin-body">
<aside class="sidebar">
    <div class="brand">
        <span class="brand-mark">K</span>
        <div>
            <strong>Kutuku Admin</strong>
            <small>{{ auth('admin')->user()->role?->label() }}</small>
        </div>
        <span class="brand-chevron" aria-hidden="true">▾</span>
    </div>

    <div class="sidebar-search" aria-hidden="true">
        <span>Search</span>
        <kbd>/</kbd>
    </div>

    <nav class="nav">
        <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">Dashboard</a>

        <div class="nav-section">Work</div>
        <a href="{{ route('admin.visitors.index') }}" class="{{ request()->routeIs('admin.visitors.*') ? 'active' : '' }}">User Management</a>
        <a href="{{ route('admin.rfid.bind') }}" class="{{ request()->routeIs('admin.rfid.bind*') ? 'active' : '' }}">Bind RFID Card</a>
        <a href="{{ route('admin.rfid.scans') }}" class="{{ request()->routeIs('admin.rfid.scans') ? 'active' : '' }}">RFID Scan Log</a>
        <a href="{{ route('admin.gallery.index') }}" class="{{ request()->routeIs('admin.gallery.*') ? 'active' : '' }}">Photo Gallery</a>

        <div class="nav-section">Store</div>
        <a href="{{ route('admin.products.index') }}" class="{{ request()->routeIs('admin.products.*') ? 'active' : '' }}">Products</a>
        <a href="{{ route('admin.orders.index') }}" class="{{ request()->routeIs('admin.orders.*') ? 'active' : '' }}">Orders</a>

        @if(auth('admin')->user()?->isSuperadmin())
            <div class="nav-section">Team</div>
            <a href="{{ route('admin.staff.index') }}" class="{{ request()->routeIs('admin.staff.*') ? 'active' : '' }}">Admin Management</a>
            <a href="{{ route('admin.analytics') }}" class="{{ request()->routeIs('admin.analytics') ? 'active' : '' }}">Analytics</a>
            <a href="{{ route('admin.activity.index') }}" class="{{ request()->routeIs('admin.activity.*') ? 'active' : '' }}">Activity Log</a>
        @endif
    </nav>

    <div class="sidebar-user" id="sidebar-user">
        <button type="button" class="sidebar-user-trigger" id="sidebar-user-trigger" aria-expanded="false" aria-controls="sidebar-user-menu">
            <span class="user-avatar">{{ strtoupper(substr(auth('admin')->user()->name, 0, 1)) }}</span>
            <span class="user-meta">
                <strong>{{ auth('admin')->user()->name }}</strong>
                <span>{{ auth('admin')->user()->email }}</span>
            </span>
        </button>
        <div class="sidebar-user-menu" id="sidebar-user-menu" role="menu">
            <div style="padding: 8px 12px 4px;">
                <strong style="display:block;font-size:13px;">{{ auth('admin')->user()->name }}</strong>
                <span class="muted" style="font-size:12px;">{{ auth('admin')->user()->role?->label() }}</span>
            </div>
            <hr>
            @if(auth('admin')->user()?->isSuperadmin())
                <a href="{{ route('admin.staff.index') }}" role="menuitem">Admin Management</a>
            @endif
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="danger" role="menuitem">Log out</button>
            </form>
        </div>
    </div>
</aside>

<main class="content">
    <header class="topbar">
        <div>
            <h1>@yield('heading', 'Dashboard')</h1>
            @hasSection('subheading')
                <p class="muted">@yield('subheading')</p>
            @endif
        </div>
        <div class="topbar-user">{{ auth('admin')->user()->name }}</div>
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

<script>
    (function () {
        var root = document.getElementById('sidebar-user');
        var trigger = document.getElementById('sidebar-user-trigger');
        if (!root || !trigger) return;

        trigger.addEventListener('click', function (e) {
            e.stopPropagation();
            var open = root.classList.toggle('open');
            trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
        });

        document.addEventListener('click', function () {
            root.classList.remove('open');
            trigger.setAttribute('aria-expanded', 'false');
        });
    })();
</script>
@stack('scripts')
</body>
</html>
