function jwt {
	echo "$1" | python3 -c "
import sys, base64, json
token = sys.stdin.read().strip().split('.')
header = token[0]
payload = token[1]

# Decode header
header_padding = '=' * (4 - len(header) % 4)
header_data = json.loads(base64.urlsafe_b64decode(header + header_padding))
print('=== HEADER ===')
print(json.dumps(header_data, indent=2))

# Decode payload
payload_padding = '=' * (4 - len(payload) % 4)
payload_data = json.loads(base64.urlsafe_b64decode(payload + payload_padding))
print('\n=== PAYLOAD ===')
print(json.dumps(payload_data, indent=2))

# Pretty print expiration time
if 'exp' in payload_data:
    import datetime
    exp_timestamp = payload_data['exp']
    exp_datetime = datetime.datetime.fromtimestamp(exp_timestamp)
    now = datetime.datetime.now()

    print('\n=== EXPIRATION ===')
    print(f'Expires at: {exp_datetime.strftime(\"%Y-%m-%d %H:%M:%S\")}')

    if exp_datetime > now:
        time_left = exp_datetime - now
        total_seconds = int(time_left.total_seconds())

        if total_seconds < 60:
            print(f'Time left: {total_seconds}s')
        elif total_seconds < 3600:
            minutes = total_seconds // 60
            seconds = total_seconds % 60
            print(f'Time left: {minutes}m {seconds}s')
        else:
            hours = total_seconds // 3600
            minutes = (total_seconds % 3600) // 60
            print(f'Time left: {hours}h {minutes}m')
    else:
        time_ago = now - exp_datetime
        total_seconds = int(time_ago.total_seconds())

        if total_seconds < 60:
            print(f'Expired {total_seconds}s ago')
        elif total_seconds < 3600:
            minutes = total_seconds // 60
            print(f'Expired {minutes}m ago')
        else:
            hours = total_seconds // 3600
            minutes = (total_seconds % 3600) // 60
            print(f'Expired {hours}h {minutes}m ago')
else:
    print('\n=== EXPIRATION ===')
    print('No expiration time found in token')
"
}
