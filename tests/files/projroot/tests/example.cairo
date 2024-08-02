#[cfg(test)]
mod tests {
    fn not_a_test() {
    }

    #[test]
    fn reg_test() {
        assert_eq!(1, 1, "1");
    }

    #[test]
    #[should_panic(expected: ('panic!!!',))]
    fn test_panicing() {
        assert(false, "panic!!!");
    }
}
