/* eslint no-param-reassign: ["error", {
  "props": true, "ignorePropertyModificationsFor": ["field", "model"]
}] */
import { observable, computed, when, action } from 'mobx';
import {
    extend, isObject, isFunction, mapValues, every, get, filter, isNil,
} from 'lodash';


class Field {
    name: '';
    @observable isTouched = false
    @observable value = '';
    @observable message = '';

    constructor(name, attrs) {
        this.name = name;
        let extendWith = isFunction(attrs) ? attrs() : attrs;
        if (!isObject(extendWith)) {
            extendWith = { test: extendWith };
        }
        extend(this, extendWith);
        if (this.default) {
            this.value = this.default;
        }
    }

    @action.bound
    onChange(ev) {
        this.value = ev.target.value;
    }

    @action.bound
    onBlur() {
        this.isTouched = true;
    }

    @computed get isValid() {
        return !!(!this.test || this.test(this.value));
    }

    @computed get invalidMessage() {
        return (!this.isValid && this.isTouched) ? this.message : null;
    }

    get events() {
        return {
            onBlur: this.onBlur,
            onChange: this.onChange,

        };
    }
}


export default class FormFieldDefinitions {

    fields = observable.map();

    constructor(fields) {
        this.fields.replace(
            mapValues(fields, (field, name) => new Field(name, field)),
        );
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

    get(name) {
        return this.fields.get(name);
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
