@extends('admin.layouts.app')

@section('title', 'Photo Gallery')
@section('heading', 'Wahana photo gallery')
@section('subheading', 'RFID face captures grouped by member.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.gallery.index') }}">
        <input class="search" type="search" name="q" value="{{ $q }}" placeholder="Search name, email, RFID UID, member code…">
        <button class="btn secondary" type="submit">Search</button>
    </form>
</div>

@forelse($groups as $group)
    <div class="panel">
        <div class="panel-header">
            <div>
                <h2>{{ $group['name'] }}</h2>
                <div class="muted">
                    {{ $group['email'] ?? '—' }}
                    · Member {{ $group['member_code'] ?? '—' }}
                    · RFID <code>{{ $group['rfid_uid'] ?? '—' }}</code>
                </div>
            </div>
            <span class="badge neutral">{{ $group['count'] }} photo{{ $group['count'] === 1 ? '' : 's' }}</span>
        </div>
        <div class="gallery">
            @foreach($group['photos'] as $photo)
                <article class="gallery-card">
                    <a href="{{ route('admin.gallery.show', $photo) }}" target="_blank" rel="noopener">
                        <img src="{{ route('admin.gallery.show', $photo) }}" alt="Capture {{ $photo->id }}">
                    </a>
                    <div class="meta">
                        <div class="muted">{{ $photo->created_at?->format('Y-m-d H:i') }}</div>
                        <div class="muted">{{ $photo->status }}</div>
                    </div>
                </article>
            @endforeach
        </div>
    </div>
@empty
    <div class="panel">No captured photos yet.</div>
@endforelse
@endsection
