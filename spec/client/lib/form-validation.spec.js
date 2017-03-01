import { buildValidations, nonBlank, validEmail, hasLength, validation } from 'lanes/lib/form-validation';

describe('Form Validation functions', () => {
    it('builds tests using blank', () => {
        const validations = buildValidations({
            name: nonBlank,
            good: nonBlank({ message: 'Name IS NO GOOD!', critical: false }),
        });
        expect(validations.name.tests).toHaveLength(1);
        expect(validations.name.tests[0].test(undefined)).toBe(false);
        expect(validations.name.tests[0].test('')).toBe(false);
        expect(validations.name.tests[0].test(null)).toBe(false);
        expect(validations.name.tests[0].test('   ')).toBe(false);
        expect(validations.name.tests[0].test('a')).toBe(true);
        expect(validations.name.tests[0].failProps.errorText).toEqual('is required');
        expect(validations.good.tests[0].failProps.errorText).toEqual('Name IS NO GOOD!');
        expect(validations.good.tests[0].critical).toBe(false);
    });
    it('builds tests using email', () => {
        const validations = buildValidations({
            email: validEmail,
        });
        expect(validations.email.tests).toHaveLength(1);
        expect(validations.email.tests[0].test('a')).toBe(false);
        expect(validations.email.tests[0].test('test')).toBe(false);
        expect(validations.email.tests[0].test('@test.com')).toBe(false);
        expect(validations.email.tests[0].test('test@test.com')).toBe(true);
        expect(validations.email.tests[0].failProps.errorText).toEqual('must be a valid email');
    });
    it('tests hasLength', () => {
        const validations = buildValidations({
            name: hasLength(3),
        });
        expect(validations.name.tests[0].test('a')).toBe(false);
        expect(validations.name.tests[0].test('abc')).toBe(true);
    });
    it('can use custom options', () => {
        const test = jest.fn(() => true);
        const { name } = buildValidations({
            name: validation({ test, critical: false }),
        });
        expect(name.tests[0].critical).toBe(false);
        expect(name.tests[0].test('a')).toBe(true);
        expect(test).toHaveBeenCalledWith('a');
    });
});
