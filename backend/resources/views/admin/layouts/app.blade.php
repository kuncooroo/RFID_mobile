<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin') — WanderDesa</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('css/admin.css') }}">
</head>

<body class="admin-body">
    <div class="sidebar-backdrop" id="sidebar-backdrop" hidden></div>

    <aside class="sidebar" id="admin-sidebar" aria-label="Admin navigation">
        <div class="sidebar-mobile-head">
            <div class="brand brand-compact">
                <span class="brand-mark">W</span>
                <div>
                    <strong>WanderDesa Admin</strong>
                </div>
            </div>
            <button type="button" class="icon-btn sidebar-close" id="sidebar-close" aria-label="Close menu">
                <span aria-hidden="true">&times;</span>
            </button>
        </div>

        <div class="brand brand-desktop">
            <span class="brand-mark">W</span>
            <div>
                <strong>WanderDesa Admin</strong>
            </div>
            <span class="brand-chevron" aria-hidden="true">▾</span>
        </div>

        @php $adminUser = auth('admin')->user(); @endphp
        <nav class="nav">
            @if($adminUser?->allows('dashboard.view'))
            <a href="{{ route('admin.dashboard') }}" class="{{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">Dashboard</a>
            @endif

            <div class="nav-section">Operasional</div>
            @if($adminUser?->allows('visitors.manage'))
            <a href="{{ route('admin.visitors.index') }}" class="{{ request()->routeIs('admin.visitors.*') ? 'active' : '' }}">Pengunjung</a>
            @endif
            @if($adminUser?->allows('experiences.manage'))
            <a href="{{ route('admin.experiences.index') }}" class="{{ request()->routeIs('admin.experiences.*') ? 'active' : '' }}">Experience</a>
            @endif
            @if($adminUser?->allows('rfid.manage'))
            <a href="{{ route('admin.rfid.bind') }}" class="{{ request()->routeIs('admin.rfid.bind*') ? 'active' : '' }}">Kartu RFID</a>
            <a href="{{ route('admin.rfid.scans') }}" class="{{ request()->routeIs('admin.rfid.scans') ? 'active' : '' }}">Log scan</a>
            @endif

            <div class="nav-section">Tiket dan toko</div>
            @if($adminUser?->allows('products.manage'))
            <a href="{{ route('admin.products.index') }}" class="{{ request()->routeIs('admin.products.*') ? 'active' : '' }}">Produk</a>
            @endif
            @if($adminUser?->allows('orders.manage'))
            <a href="{{ route('admin.orders.index') }}" class="{{ request()->routeIs('admin.orders.*') ? 'active' : '' }}">Pesanan</a>
            @endif
            @if($adminUser?->allows('analytics.view'))
            <a href="{{ route('admin.analytics') }}" class="{{ request()->routeIs('admin.analytics') ? 'active' : '' }}">Analitik</a>
            @endif

            @if($adminUser?->allows('cashier.manage') || $adminUser?->allows('finance.manage'))
            <div class="nav-section">Keuangan</div>
            @endif
            @if($adminUser?->allows('cashier.manage') || $adminUser?->allows('finance.manage'))
            <a href="{{ route('admin.cashier') }}" class="{{ request()->routeIs('admin.cashier') ? 'active' : '' }}">Kasir</a>
            @endif
            @if($adminUser?->allows('finance.manage'))
            <a href="{{ route('admin.cashflow') }}" class="{{ request()->routeIs('admin.cashflow') ? 'active' : '' }}">Arus uang</a>
            @endif

            <div class="nav-section">Tim</div>
            @if($adminUser?->allows('staff.manage'))
            <a href="{{ route('admin.staff.index') }}" class="{{ request()->routeIs('admin.staff.*') ? 'active' : '' }}">Akun staf</a>
            @endif
            @if($adminUser?->allows('permissions.manage'))
            <a href="{{ route('admin.permissions.edit') }}" class="{{ request()->routeIs('admin.permissions.*') ? 'active' : '' }}">Izin peran</a>
            @endif
            @if($adminUser?->allows('activity.view'))
            <a href="{{ route('admin.activity.index') }}" class="{{ request()->routeIs('admin.activity.*') ? 'active' : '' }}">Log aktivitas</a>
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
                <form method="POST" action="{{ route('admin.logout') }}">
                    @csrf
                    <button type="submit" class="danger" role="menuitem">
                        Log out
                    </button>
                </form>
            </div>
        </div>
    </aside>

    <main class="content">
        <header class="topbar">
            <div class="topbar-main">
                <button type="button" class="icon-btn hamburger" id="sidebar-toggle" aria-label="Open menu" aria-controls="admin-sidebar" aria-expanded="false">
                    <span class="hamburger-lines" aria-hidden="true">
                        <span></span>
                        <span></span>
                        <span></span>
                    </span>
                </button>
                <div class="topbar-titles">
                    <h1>@yield('heading', 'Dashboard')</h1>

                    @hasSection('subheading')
                    <p class="muted">@yield('subheading')</p>
                    @endif
                </div>
            </div>
        </header>

        @if(session('success'))
        <div class="alert success">{{ session('success') }}</div>
        @endif

        @if(session('error'))
        <div class="alert danger">{{ session('error') }}</div>
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
        (function() {
            var body = document.body;
            var sidebar = document.getElementById('admin-sidebar');
            var backdrop = document.getElementById('sidebar-backdrop');
            var toggle = document.getElementById('sidebar-toggle');
            var closeBtn = document.getElementById('sidebar-close');
            var mq = window.matchMedia('(max-width: 980px)');

            function setOpen(open) {
                body.classList.toggle('sidebar-open', open);
                if (toggle) toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
                if (backdrop) backdrop.hidden = !open;
                if (open) {
                    body.style.overflow = 'hidden';
                } else {
                    body.style.overflow = '';
                }
            }

            function closeSidebar() {
                setOpen(false);
            }

            function openSidebar() {
                setOpen(true);
            }

            if (toggle) {
                toggle.addEventListener('click', function() {
                    if (body.classList.contains('sidebar-open')) {
                        closeSidebar();
                    } else {
                        openSidebar();
                    }
                });
            }

            if (closeBtn) closeBtn.addEventListener('click', closeSidebar);
            if (backdrop) backdrop.addEventListener('click', closeSidebar);

            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') closeSidebar();
            });

            if (sidebar) {
                sidebar.querySelectorAll('a').forEach(function(link) {
                    link.addEventListener('click', function() {
                        if (mq.matches) closeSidebar();
                    });
                });
            }

            function onMqChange() {
                if (!mq.matches) closeSidebar();
            }
            if (mq.addEventListener) mq.addEventListener('change', onMqChange);
            else if (mq.addListener) mq.addListener(onMqChange);

            var root = document.getElementById('sidebar-user');
            var trigger = document.getElementById('sidebar-user-trigger');
            if (!root || !trigger) return;

            trigger.addEventListener('click', function(e) {
                e.stopPropagation();
                var open = root.classList.toggle('open');
                trigger.setAttribute('aria-expanded', open ? 'true' : 'false');
            });

            document.addEventListener('click', function() {
                root.classList.remove('open');
                trigger.setAttribute('aria-expanded', 'false');
            });
        })();
    </script>
    @stack('scripts')
</body>

</html>
