@extends('admin.layouts.app')

@section('title', $visitor->name)
@section('heading', $visitor->name)
@section('subheading', 'Detail visitor & riwayat kunjungan RFID')

@section('content')
<div class="toolbar">
    <a class="btn secondary" href="{{ route('admin.visitors.index') }}">Back to list</a>
    <a class="btn" href="{{ route('admin.visitors.edit', $visitor) }}">Edit visitor</a>
    @if(auth('admin')->user()?->allows('experiences.manage'))
        <a class="btn secondary" href="{{ route('admin.experiences.show', $visitor) }}">Experience</a>
    @endif
</div>

<div class="visitor-meta" style="border: 1px solid var(--line); border-radius: var(--radius); overflow: hidden; margin-bottom: 18px;">
    <div class="visitor-meta-item">
        <span>Saldo</span>
        <strong>{{ number_format((float) ($visitor->member?->balance ?? 0), 0, ',', '.') }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Points</span>
        <strong>{{ (int) ($visitor->member?->points ?? 0) }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Diskon tersimpan</span>
        <strong>{{ number_format((float) ($visitor->member?->discount_credit ?? 0), 2, ',', '.') }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Visits</span>
        <strong>{{ $visitCount }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>Points earned</span>
        <strong>{{ $pointsEarned }}</strong>
    </div>
    <div class="visitor-meta-item">
        <span>RFID</span>
        <strong style="font-size: 14px;"><code>{{ $visitor->rfidMember?->rfid_uid ?? 'Not bound' }}</code></strong>
    </div>
</div>

<div class="panel" style="margin-bottom: 18px;">
    <div class="panel-header">
        <h2>Top up saldo</h2>
        <p class="muted">Saldo tersimpan di kartu. Top-up tunai di loket dicatat lewat menu Kasir saat shift terbuka, supaya uang yang diterima masuk rekonsiliasi.</p>
    </div>
    <form method="POST" action="{{ route('admin.visitors.topup', $visitor) }}" class="form-grid">
        @csrf
        <label>
            Nominal
            <input type="number" name="amount" min="0.01" step="0.01" required placeholder="10000">
        </label>
        <div class="actions" style="align-self: end;">
            <button class="btn" type="submit">Tambah saldo</button>
        </div>
    </form>
    <p class="muted" style="margin: 12px 0 0;">{{ $pointsRate }} poin = 1 diskon di checkout aplikasi user.</p>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Profile</h2>
    </div>
    <div class="form-grid">
        <div>
            <div class="muted" style="font-size: 12px; font-weight: 600;">Email</div>
            <div>{{ $visitor->email ?? '—' }}</div>
        </div>
        <div>
            <div class="muted" style="font-size: 12px; font-weight: 600;">Phone</div>
            <div>{{ $visitor->phone ?? '—' }}</div>
        </div>
        <div>
            <div class="muted" style="font-size: 12px; font-weight: 600;">Member code</div>
            <div><code>{{ $visitor->rfidMember?->member_code ?? '—' }}</code></div>
        </div>
        <div>
            <div class="muted" style="font-size: 12px; font-weight: 600;">Nomor kartu (16 digit)</div>
            <div><code>{{ $visitor->rfidMember?->card_number ?? '—' }}</code></div>
        </div>
        <div>
            <div class="muted" style="font-size: 12px; font-weight: 600;">Registered</div>
            <div>{{ $visitor->created_at?->format('Y-m-d H:i') ?? '—' }}</div>
        </div>
    </div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Face enrollment</h2>
    </div>
    <div class="face-upload-grid">
        @foreach(['front' => 'Front', 'right' => 'Right', 'left' => 'Left'] as $pose => $label)
            <div class="face-upload-card">
                <div class="face-upload-label">{{ $label }}</div>
                <div class="face-upload-preview">
                    @if($faces[$pose] ?? null)
                        <a href="{{ route('admin.visitors.face', [$visitor, $pose]) }}" target="_blank" rel="noopener">
                            <img src="{{ route('admin.visitors.face', [$visitor, $pose]) }}" alt="{{ $label }}">
                        </a>
                    @else
                        <span class="face-upload-placeholder">Belum ada foto</span>
                    @endif
                </div>
                @if($faces[$pose] ?? null)
                    <div class="muted face-upload-meta">{{ $faces[$pose]->enrolled_at?->format('Y-m-d H:i') ?? '—' }}</div>
                @endif
            </div>
        @endforeach
    </div>
</div>

<div class="panel">
    <div class="panel-header">
        <h2>Visit history</h2>
    </div>

    <form method="GET" action="{{ route('admin.visitors.show', $visitor) }}" class="filter-form" style="margin-bottom: 14px;">
        <div class="filter-row">
            <label>
                From
                <input type="date" name="date_from" value="{{ $dateFrom ?? '' }}">
            </label>
            <label>
                To
                <input type="date" name="date_to" value="{{ $dateTo ?? '' }}">
            </label>
            <div class="actions" style="align-self: end;">
                <button class="btn secondary" type="submit">Filter</button>
                <a class="btn secondary" href="{{ route('admin.visitors.show', $visitor) }}">Reset</a>
            </div>
        </div>
    </form>

    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>Time</th>
                <th>RFID</th>
                <th>Location</th>
                <th>Fare</th>
                <th>Points</th>
                <th>Status</th>
            </tr>
            </thead>
            <tbody>
            @forelse($visits as $visit)
                <tr>
                    <td>{{ ($visits->firstItem() ?? 0) + $loop->index }}</td>
                    <td>{{ $visit->checked_in_at?->format('Y-m-d H:i:s') ?? '—' }}</td>
                    <td>
                        <div><code>{{ $visit->rfidMember?->rfid_uid ?? '—' }}</code></div>
                        <div class="muted">{{ $visit->rfidMember?->member_code ?? '' }}</div>
                    </td>
                    <td>{{ $visit->location?->name ?? '—' }}</td>
                    <td>{{ number_format((float) $visit->amount_charged, 0, ',', '.') }}</td>
                    <td>
                        @if((int) $visit->points_awarded > 0)
                            <span class="badge ok">+{{ (int) $visit->points_awarded }}</span>
                        @else
                            <span class="muted">0</span>
                        @endif
                    </td>
                    <td><span class="badge {{ $visit->status === 'success' ? 'ok' : 'warn' }}">{{ $visit->status }}</span></td>
                </tr>
            @empty
                <tr><td colspan="7">Belum ada riwayat kunjungan.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $visits->links('admin.partials.pagination') }}</div>
</div>
@endsection
