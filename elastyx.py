#!/usr/bin/env python2.7

from datetime import datetime
from mrjob.emr import EMRJobRunner
from mrjob.job import MRJob
from mrjob.protocol import JSONValueProtocol
from sys import maxint
from ua_parser import user_agent_parser
import geoip2.database
import json
import re


class FlexibleEMRJobRunner(EMRJobRunner):

    def _job_flow_args(self, persistent=False, steps=None):
        args = super(FlexibleEMRJobRunner, self)._job_flow_args(persistent, steps)

        if self._opts['emr_api_params']:
            args['api_params'] = self._opts['emr_api_params']
            if self._opts['visible_to_all_users']:
                args['api_params']['VisibleToAllUsers'] = 'true'

        return args


class MRImpressionStats(MRJob):
    OUTPUT_PROTOCOL = JSONValueProtocol
    HADOOP_OUTPUT_FORMAT = 'elastyxOutput.MultiOutputFormat'

    locale_whitelist = [
        'en-us'
        ]
    #geoip_db = geoip2.database.Reader('./GeoLite2-Country.mmdb')
    ip_pattern = re.compile("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")

    newtab_keys = ['date', 'locale', 'country_code', 'os', 'browser',
                   'version', 'device', 'year', 'month', 'week']

    impression_keys = ['date', 'position', 'locale', 'tile_id',
                       'country_code', 'os', 'browser', 'version',
                       'device', 'year', 'month', 'week']

    def mapper(self, _, line):
        data = json.loads(line)

        try:
            # throw out bad data
            assert data['tiles'][0] is not None
            assert self.ip_pattern.match(data['ip'])
            assert datetime.fromtimestamp(data['timestamp'] / 1000.0)

            # parse locale
            if data['locale'].lower() in self.locale_whitelist:
                data['locale'] = data['locale']

            # parse date
            dt = datetime.strptime(data['date'], '%Y-%m-%d')
            data['year'] = dt.year
            data['month'] = dt.month
            data['week'] = dt.isocalendar()[1]

            del data['timestamp']
        except:
            # throw out invalid log
            return

        # parse ip
        try:
            ip = data['ips'].split(',')[0].strip()
            geo_resp = self.geoip_db.country(ip)
            data['country_code'] = geo_resp.country.iso_code
        except:
            data['country_code'] = 'ERROR'
        finally:
            del data['ip']

        # parse ua
        try:
            ua_dict = user_agent_parser.Parse(data['ua'])
            try:
                data['browser'] = ua_dict['user_agent']['family'][:64]
            except:
                data['browser'] = 'n/a'
            try:
                data['device'] = ua_dict['device']['family'][:64]
            except:
                data['device'] = 'n/a'
            try:
                data['os'] = ua_dict['os']['family'][:64]
            except:
                data['os'] = 'n/a'
            try:
                data['version'] = (
                    "%s.%s" % (
                        result_dict['user_agent']['major'],
                        result_dict['user_agent']['minor']
                        )
                    )[:64]
            except:
                data['version'] = 'n/a'
        except:
            pass

        # parse tiles
        try:
            # yield newtab
            yield {k: data[k] for k in self.newtab_keys}, {'newtabs': 1}

            tiles = data.get('tiles')

            values = {'clicks': 0, 'impressions': 0, 'pinned': 0, 'blocked': 0,
                    'sponsored': 0, 'sponsored_link': 0}

            impression_types = [
                # (<IMPRESSION_TYPE>, <VALUES_KEY>)
                ('block', 'blocked'),
                ('click', 'clicks'),
                ('pin', 'pinned'),
                ('sponsored', 'sponsored'),
                ('sponsored_link', 'sponsored_link'),
                # this is for everything else
                (None, 'impressions'),
                ]

            # if impression type is not None, throw out all other tiles
            for key, value in impression_types:
                # if we haven't found the type yet, move on unless type is None
                if data.get(key) is None and key is not None:
                    continue
                position = data.get(key)
                values[value] = 1
                if key is not None:
                    # we have a specific type, ignore all other tiles
                    tiles = [tiles[position]]

            assert position < 1024

            for pos, tile in enumerate(tiles):
                if tile.get('pos') is not None:
                    data['position'] = tile['pos']
                elif position is not None:
                    data['position'] = position
                else:
                    data['position'] = pos

                data['tile_id'] = tile.get('id')

                if (data['tile_id'] is not None
                        and data['tile_id'] < 1000
                        and data['position'] < data.get('view', maxint)):
                    # yield impression
                    yield {k: data[k] for k in self.impression_keys}, values
        except:
            pass


    def combiner(self, data, counts):
        counts = [count for count in counts]
        combined = {k: sum([v[k] for v in counts]) for k in counts[0]}
        yield data, combined


    def reducer(self, data, counts):
        counts = [count for count in counts]
        combined = {k: sum([v[k] for v in counts]) for k in counts[0]}
        yield None, dict(data, **combined)

    # workaround for STS bug
    def make_runner(self):
        if self.options.runner == 'emr':
            return FlexibleEMRJobRunner(**self.emr_job_runner_kwargs())
        else:
            return super(MRImpressionStats, self).make_runner(self)

if __name__ == '__main__':
    MRImpressionStats.run()
