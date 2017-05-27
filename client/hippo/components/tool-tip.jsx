import React, { PureComponent } from 'react';
import PopperJS from 'popper';
import { autobind } from 'core-decorators';

// most credit goes to: https://gist.github.com/FezVrasta/6533adf4358a6927b48f7478706a5f23#file-popper-jsx

export default class ToolTip extends PureComponent {
    state = {}

    @autobind
    update() {
        if (this.popperInstance) {
            this.popperInstance.scheduleUpdate();
        }
    }

    componentDidMount() {
        const update = data => this.setState({ data });
        this.popperInstance = new PopperJS(this.content, this.popper, {
            placement: 'top',
            modifiers: {
                arrow: { element: this.arrow },
                applyStyle: { enabled: false },
            },
            onCreate: update,
            onUpdate: update,
        });
    }

    componentWillUnmount() {
        this.popperInstance.destroy();
    }

    getPopperStyle(data) {
        if (!data) { return {}; }
        const left = Math.round(data.offsets.popper.left);
        const top = Math.round(data.offsets.popper.top);
        const transform = `translate3d(${left}px, ${top}px, 0)`;
        return {
            position: data.offsets.popper.position,
            transform,
            WebkitTransform: transform,
            top: 0,
            left: 0,
        };
    }

    getArrowStyle(data) {
        if (!data) { return {}; }
        const left = Math.round(data.offsets.arrow.left);
        const top = Math.round(data.offsets.arrow.top);
        return { position: 'absolute', top, left };
    }

    render() {
        const { children, arrow } = this.props;
        return (
            <div>
                <div
                    ref={(el) => (this.content = el)}
                    className='popper-content'
                >
                    {this.props.children[0]}
                </div>
                <div
                    ref={(el) => (this.popper = el)}
                    data-placement={this.state.data && this.state.data.placement}
                    className='popper'
                    style={this.getPopperStyle(this.state.data)}
                >
                    {this.props.children[1]}
                    {arrow && <div
                                  ref={(el) => (this.arrow = el)}
                                  className='arrow'
                                  style={this.getArrowStyle(this.state.data)}
                              />}
                </div>
            </div>
        );
    }
}
