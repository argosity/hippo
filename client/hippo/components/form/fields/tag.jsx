import React from 'react';
import { isEmpty, isArray } from 'lodash';
import { observer } from 'mobx-react';
import { toJS, computed, action, isObservableArray } from 'mobx';
import Select from 'react-select';
import { css } from 'styled-components';
import 'react-select/dist/react-select.css';
import { isArrayLike } from '../../../lib/util';

@observer
export default class TagsWrapper extends React.Component {

    static styles() {
        return css`
            .Select {
                flex: 1;
            }
        `;
    }

    get tags() {
        if (isEmpty(this.props.value)) {
            return [];
        } if (!isArray(this.props.value)
            && !isObservableArray(this.props.value)) {
            return [this.props.value];
        }
        return this.props.suggestions;
    }

    @action.bound
    onTagDelete(tagIndex) {
        const { tags } = this;
        tags.splice(tagIndex, 1);
        this.props.onChange({ target: { value: tags } });
    }

    @action.bound onTagAdd(tag) {
        const { tags } = this;
        tags.push(tag);
        this.props.onChange({ target: { value: tags } });
    }

    @action.bound onChange(value) {
        this.props.onChange({ target: { value } });
    }

    @computed get values() {
        const { props: { value } } = this;
        if (isArrayLike(value)) {
            return toJS(value);
        }
        return value;
    }

    onNewOption({ label, labelKey }) {
        return { [`${labelKey}`]: label };
    }

    render() {
        const { suggestions, value: _, ...otherProps } = this.props;

        return (
            <Select.Creatable
                multi
                handleDelete={this.onTagDelete}
                newOptionCreator={this.onNewOption}
                handleAddition={this.onTagAdd}
                options={suggestions}
                {...otherProps}
                value={this.values}
                valueArray={this.values}
                onChange={this.onChange}
            />
        );
    }

}
