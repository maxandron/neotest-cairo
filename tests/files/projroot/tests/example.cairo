#[cfg(test)]
mod tests {
    fn not_a_test() {
    }

    #[test]
    fn failing_test1() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test1() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking1() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test2() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test2() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking2() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test3() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test3() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking3() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test4() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test4() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking4() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test5() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test5() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking5() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test6() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test6() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking6() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test7() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test7() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking7() {
        assert(false, 'panic!!!');
    }
    #[test]
    fn failing_test8() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test8() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking8() {
        assert(false, 'panic!!!');
    }

    #[test]
    fn failing_test9() {
        assert_eq!(1, 2, "expecting one");
    }

    #[test]
    fn example_test9() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicking9() {
        assert(false, 'panic!!!');
    }
}
