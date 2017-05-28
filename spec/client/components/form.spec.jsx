import React from 'react';
import {
    nonBlank, validEmail, hasLength, validURL, FormState,
} from 'hippo/components/form';

describe('Form Validation functions', () => {
    it('validates fields', () => {
        const form = new FormState();
        form.setFields({
            email: { validate: validEmail },
            name:  { validate: hasLength({ length: 3 }) },
        });
        expect(form.fields.get('email').isValid).toBe(false);
        expect(form.isValid).toBe(false);
        expect(form.isTouched).toBe(false);

        expect(form.get('email').isValid).toBe(false);
        form.get('email').value = 'test@test.com';
        expect(form.get('email').isValid).toBe(true);

        form.fields.get('email').isTouched = true;
        expect(form.isTouched).toBe(true);
        form.fields.get('name').value = '';
        form.fields.get('name').onBlur();
        expect(form.isValid).toBe(false);

        form.fields.get('name').onChange({ target: { value: 'a value' } });
        expect(form.isValid).toBe(true);
    });

    it('builds tests using blank', () => {
        const test = nonBlank();
        expect(test.message).toEqual('is required');
        expect(test.test(undefined)).toBe(false);
        expect(test.test('')).toBe(false);
        expect(test.test('')).toBe(false);
        expect(test.test(null)).toBe(false);
        expect(test.test('a')).toBe(true);
    });

    it('builds tests using email', () => {
        const test = validEmail({ message: 'YO FIX IT' });
        expect(test.message).toContain('YO');
        expect(test.test('a')).toBe(false);
        expect(test.test('test')).toBe(false);
        expect(test.test('@test.com')).toBe(false);
        expect(test.test('test@test.com')).toBe(true);
    });

    it('tests hasLength', () => {
        const len = hasLength(3);
        expect(len.test('a')).toBe(false);
        expect(len.test('abc')).toBe(true);
    });

    it('tests url', () => {
        let url = validURL();
        expect(url.test('bad-url')).toBe(false);
        expect(url.test('')).toBe(false);
        url = validURL({ allowBlank: true });
        expect(url.test('')).toBe(true);
    });
});
