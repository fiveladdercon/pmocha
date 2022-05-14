describe("pmocha", sub {

	describe("the 'describe' API", sub {

		it("groups tests under headings", sub {
			assert(1);
		});

		it("groups at mulitple levels", sub {
			assert(1);
		});

	});

	xdescribe("the 'xdescribe' API", sub {

		it("skips the group of tests it contains", sub {
			&fail("This wasn't skipped!");
		});

	});

	describe("the 'it' API", sub {

		it("declares the test intent with the test implementation", sub {
			expect(1 + 1, 2);
		});

		it("skips the test when there is no callback");

	});

	describe("the 'xit' API", sub {

		xit("skips the test", sub {
			&fail("This wasn't skipped!");
		});

	});

	describe("the 'fail' API", sub {

		it("fails the test without a message", sub {
			&fail;
		});

		it("fails a test with a message", sub {
			&fail("this fail is actually expected!");
		});
	
	});

	describe("the 'assert' API", sub {

		it("passes the test when the result is truthy", sub {
			assert(1+1 == 2);
		});

		it("fails the test when the result is falsey", sub {
			assert(1 == 2, "This fail is actually expected!");
		});

	});

	describe("the 'expect' API", sub {

		it("passes the test when the actual equals the expected", sub {
			expect(1+1, 2);
		});

		it("fails the test when the actual does not equal the expected", sub {
			expect(1, 2);
		});

	});

});