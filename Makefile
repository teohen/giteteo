build:
	zig build-exe -target x86_64-linux-gnu main.zig
run: 
	zig run main.zig
start: 
	zig build-exe -target x86_64-linux-gnu main.zig && ./main -s teste.txt

