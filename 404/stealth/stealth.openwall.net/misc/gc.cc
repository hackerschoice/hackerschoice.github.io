// Small garbage collector/local scope class for C++ to automagically
// call the correct release-function for the right type e.g.
// you dont need to fclose(f) after every if() error-clause
// before returning if you fopen'ed a file. Similar for
// memory obtained with new, new[], malloc() etc or files
// opened with open(2).
//
// (C) 2009 stealth [at openwall.net] under the GPL.
//
// Note that this is actually some cool hack :)
// I think this only works because the compiler is optimizing away
// constructors for types it doesnt need e.g. an instance of
// "local_scope<int> lc(fd, close)" will actually not build
// the f1 and f2 kind of constructors so it will never complain
// about a mismatch of a assignment of an "int" to a "mem_obj" ptr.
// Its all about to overload the constructors with a different
// release-signature and luckily all of them have a different signature :)
//
// Please send approvements to me if you have any.
//
// $ c++ -Wall -ansi -pedantic gc.cc
// Tested with GCC 4.1

#include <cstdio>
#include <string>

template<class T>
class local_scope {
	T obj;
	int int_obj;
	FILE *FILE_obj;
	void *mem_obj;

	void (*release_mem)(void *);
	int (*release_FILE)(FILE *);
	int (*release_fd)(int);

	// Need to implement ref-counting and such
	template<class C> local_scope<C> &operator=(local_scope<C>&);
	local_scope(const local_scope&);
public:

	local_scope(T o)
	{
		obj = o;
	}


	// memory/object
	local_scope(T o, void (*f1)(void *))
		: obj(o), int_obj(-1), mem_obj(o), release_mem(f1),
	          release_FILE(NULL), release_fd(NULL)
	{
	}

	// FILE *
	local_scope(T o, int (*f2)(FILE *))
		: obj(o), int_obj(-1), FILE_obj(o), mem_obj(NULL),
	          release_mem(NULL), release_FILE(f2), release_fd(NULL)
	{
	}

	// file descriptor
	local_scope(T o, int (*f3)(int))
		: obj(o), int_obj(o), FILE_obj(NULL), mem_obj(NULL),
	          release_mem(NULL), release_FILE(NULL), release_fd(f3)
	{
	}

	~local_scope()
	{
		if (release_mem) {
			release_mem(mem_obj);
		} else if (release_FILE && FILE_obj != NULL) {
			release_FILE(FILE_obj);
		} else if (release_fd && int_obj >= 0) {
			release_fd(int_obj);
		}
	}

	bool fail()
	{
		if (release_fd && int_obj < 0)
			return 1;
		if (release_mem && mem_obj == NULL)
			return 1;
		if (release_FILE && FILE_obj == NULL)
			return 1;
		return 0;
	}

	bool good()
	{
		return !fail();
	}

	T &get() { return obj; }

	// This one is very cute:
	operator T&() { return obj; }
};



#include <fcntl.h>
#include <cerrno>

class Point {

public:
	int x, y;

	Point() : x(1), y(2) {}
	~Point() { printf("Destructor of point called (%d,%d)\n", x, y); }

	static void delete_one(void *one)
	{
		delete static_cast<Point *>(one);
	}

	static void delete_more(void *a)
	{
		delete [] static_cast<Point *>(a);
	}
};


int main()
{
	local_scope<int> fd(open("/etc/group", O_RDONLY), close);
	local_scope<int> fd2(open("/dev/foobar", O_RDONLY), ::close);
	local_scope<Point *> p2(new Point, Point::delete_one);
	local_scope<FILE *> f(fopen("/etc/passwd", "r"), fclose);

	// do not know whether the following two are correct, since
	// delete on void * is unspecified. Need to ask Scott Meyers :)
	// However on built-in type it seems to work
	local_scope<char *> ptr(new char[1024], operator delete[]);
	local_scope<int *> ints(new int[10000], operator delete[]);

	local_scope<Point *> p(new Point[10], Point::delete_more);
	local_scope<char *> mem((char *)malloc(1000), free);


	if (fd2.fail())
		fprintf(stderr, "Error: %s\n", strerror(errno));

	Point &p3 = p[9];
	p3.x = 73;
	p3.y = 50;
	Point &p4 = p.get()[8];
	p4.x = 42;
	p4.y = 41;

	do {
		memset(ptr.get(), 0, 1024);
		fgets(ptr.get(), 1024, f.get());
		printf("%s", ptr.get());
	} while (!feof(f.get()));


	for (;;) {
		memset(mem.get(), 0, 1000);
		int r = read(fd, mem, 1000);
		if (r <= 0)
			break;
		write(1, mem.get(), r);
	}

	return 0;
}

