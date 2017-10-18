import React from 'react';
import { isEmpty, isArray } from 'lodash';
import { observer } from 'mobx-react';
import { action, isObservableArray } from 'mobx';
import Tags from 'react-tag-autocomplete';

@observer
export default class CheckBoxWrapper extends React.PureComponent {

    get tags() {
        if (isEmpty(this.props.value)) {
            return [];
        } else if (!isArray(this.props.value) &&
                   !isObservableArray(this.props.value)) {
            return [this.props.value];
        }
        return this.props.value;
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

    render() {
        const { value: _, ...otherProps } = this.props;

        return (
            <Tags
                handleDelete={this.onTagDelete}
                handleAddition={this.onTagAdd}
                tags={isObservableArray(this.tags) ? this.tags.peek() : this.tags}
                {...otherProps}
            />
        );
    }

}
