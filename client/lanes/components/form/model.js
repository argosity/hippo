/* eslint no-param-reassign: ["error", { "props": true, "ignorePropertyModificationsFor": ["field", "model"] }] */
import { observable, computed, when, action, } from 'mobx';
import {
    extend, isObject, isFunction, mapValues, every, find, get,
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
        if (false === this.isValid) { this.runTest(); }
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

    @computed get isValid() {
        return every(this.fields.values(), 'isValid');
    }

    @computed get isTouched() {
        return !every(this.fields.values(), { isTouched: false });
    }

    get(name) {
        return this.fields.get(name);
    }

    set(values) {
        this.fields.forEach((field, name) => (field.value = values[name]));
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
