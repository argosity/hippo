/* eslint no-param-reassign: ["error", {
  "props": true, "ignorePropertyModificationsFor": ["field", "model"]
}] */
import { observable, computed, when, action } from 'mobx';
import {
    pick, isFunction, mapValues, every, get, filter, isNil, each,
} from 'lodash';

export class FormField {
    name: '';
    @observable isTouched = false
    @observable value = '';
    @observable message = '';
    @observable isChanged = '';
    @observable help;
    @observable validate;
    @observable default;

    constructor(name, attrs) {
        this.name = name;
        this.update(attrs);
        if (this.default) {
            this.value = this.default;
        }
    }

    update(attrs) {
        each(pick(attrs, [
            'name', 'default', 'help', 'validate',
        ]), (v, k) => {
            this[k] = isFunction(v) ? v.call(this) : v;
        });
    }

    @action.bound
    onChange({ target: { value: updatedValue } }) {
        this.isChanged = (this.value !== updatedValue);
        this.value = updatedValue;
    }

    @action.bound
    onBlur() {
        this.isTouched = true;
    }

    @computed get isValid() {
        if (!this.validate) { return true; }
        return !!this.validate.test(this.value);
    }

    @computed get invalidMessage() {
        return (!this.isValid && this.isTouched) ? this.validate.message : null;
    }

    get events() {
        return {
            onBlur: this.onBlur,
            onChange: this.onChange,

        };
    }
}


export class FormState {

    fields = observable.map();

    @action
    setFields(fields) {
        this.fields.replace(
            mapValues(fields, (field, name) => new FormField(name, field)),
        );
    }

    @action
    setField(name, attrs) {
        let field = this.fields.get(name);
        if (field) {
            field.update(attrs);
        } else {
            field = new FormField(name, attrs);
            this.fields.set(name, field);
        }
        return field;
    }

    @computed get invalidFields() {
        return filter(this.fields.values(), { isValid: false });
    }

    @computed get isValid() {
        return 0 === this.invalidFields.length;
    }

    @computed get isTouched() {
        return !every(this.fields.values(), { isTouched: false });
    }

    get(path, defaultValue) {
        const [name, ...rest] = path.split('.');
        const field = this.fields.get(name);
        if (!field) { return defaultValue; }
        if (rest.length) {
            return get(field, rest.join('.'), defaultValue);
        }
        return field;
    }

    set(values) {
        this.fields.forEach((field, name) => (field.value = isNil(values[name]) ? '' : values[name]));
    }

    setFromModel(model) {
        if (get(model, 'syncInProgress.isFetch')) {
            when(
                () => !get(model, 'syncInProgress.isFetch'),
                () => this.set(model),
            );
        } else {
            this.set(model);
        }
    }

    persistTo(model) {
        this.fields.forEach((field, name) => (model[name] = field.value));
        return Promise.resolve(model);
    }

}
