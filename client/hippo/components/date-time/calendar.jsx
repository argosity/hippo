import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import cx from 'classnames';
import range from 'lodash/range';
import chunk from 'lodash/chunk';
import Header from 'grommet/components/Header';
import Button from 'grommet/components/Button';
import Title from 'grommet/components/Title';
import LinkPreviousIcon from 'grommet/components/icons/base/LinkPrevious';
import LinkNextIcon from 'grommet/components/icons/base/LinkNext';

const Day = ({ i, w, d, className, ...props }) => {
    const prevMonth = w === 0 && i > 7;
    const nextMonth = w >= 4 && i <= 14;
    const cls = cx(className, {
        'prev-month': prevMonth,
        'next-month': nextMonth,
        'current-day': !prevMonth && !nextMonth && i === d
    });

    return <td className={cls} {...props}>{i}</td>;
};


@observer
export default class Calendar extends React.PureComponent {

    static propTypes = {
        moment: PropTypes.object.isRequired,
        onChange: PropTypes.func.isRequired,
    }

    @action.bound
    selectDate(i, w) {
        const prevMonth = w === 0 && i > 7;
        const nextMonth = w >= 4 && i <= 14;
        const m = this.props.moment;

        m.date(i);
        if (prevMonth) m.subtract(1, 'month');
        if (nextMonth) m.add(1, 'month');
        this.props.onChange(m);
        this.forceUpdate();
    }

    @action.bound
    prevMonth(e) {
        e.preventDefault();
        this.props.onChange(this.props.moment.subtract(1, 'month'));
        this.forceUpdate();
    }

    @action.bound
    nextMonth(e) {
        e.preventDefault();
        this.props.onChange(this.props.moment.add(1, 'month'));
        this.forceUpdate();
    }

    render() {
        const m = this.props.moment;
        const d = m.date();
        const d1 = m.clone().subtract(1, 'month').endOf('month').date();
        const d2 = m.clone().date(1).day();
        const d3 = m.clone().endOf('month').date();
        const days = [].concat(
            range(d1 - d2 + 1, d1 + 1),
            range(1, d3 + 1),
            range(1, 42 - d3 - d2 + 1),
        );
        const weeks = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

        return (
            <div className={cx('calendar', this.props.className)}>

                <Header key='header' justify='between'>
                    <Button className="previous" icon={<LinkPreviousIcon />} onClick={this.prevMonth} />
                    <Title className="title" responsive={false}>
                        {m.format('MMMM YYYY')}
                    </Title>
                    <Button className="next" icon={<LinkNextIcon />} onClick={this.nextMonth} />
                </Header>

                <div className="grid">
                    <table>
                        <thead>
                            <tr>
                                {weeks.map((w, i) => <td key={i}>{w}</td>)}
                            </tr>
                        </thead>

                        <tbody>
                            {chunk(days, 7).map((row, w) =>
                                <tr key={w}>
                                    {row.map(i =>
                                        <Day
                                            key={i}
                                            i={i}
                                            d={d}
                                            w={w}
                                            onClick={() => this.selectDate(i, w)}
                                        />,
                                    )}
                                </tr>,
                            )}
                        </tbody>
                    </table>
                </div>
            </div>
        );
    }
}
