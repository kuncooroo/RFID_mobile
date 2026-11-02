@extends('admin.layouts.app')

@section('title', 'Experience')
@section('heading', 'Experience pengunjung')
@section('subheading', 'Simpan gambar pengalaman untuk tiap pengunjung.')

@section('content')
<div class="toolbar">
    <form method="GET" action="{{ route('admin.experiences.index') }}">
        <input class="search" type="search" name="q" value="{{ $q ?? '' }}" placeholder="Cari nama, email, telepon…">
        <button class="btn secondary" type="submit">Cari</button>
    </form>
</div>

<div class="panel">
    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th>No</th>
                <th>Pengunjung</th>
                <th>Kartu</th>
                <th>Gambar tersimpan</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            @forelse($visitors as $visitor)
                <tr>
                    <td>{{ ($visitors->firstItem() ?? 0) + $loop->index }}</td>
                    <td>
                        <strong>{{ $visitor->name }}</strong>
                        <div class="muted">{{ $visitor->email ?? $visitor->phone ?? '—' }}</div>
                    </td>
                    <td><code>{{ $visitor->rfidMember?->rfid_uid ?? '—' }}</code></td>
                    <td>{{ number_format($visitor->experiences_count) }}</td>
                    <td class="actions">
                        <a class="btn sm" href="{{ route('admin.experiences.show', $visitor) }}">Kelola gambar</a>
                    </td>
                </tr>
            @empty
                <tr><td colspan="5">Belum ada pengunjung.</td></tr>
            @endforelse
            </tbody>
        </table>
    </div>
    <div class="pagination">{{ $visitors->links('admin.partials.pagination') }}</div>
</div>
@endsection
