import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailScreen extends StatefulWidget {
  final dynamic detailItem;
  final String detailType;

  DetailScreen({required this.detailItem, required this.detailType});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic> detailedInfoMap = {};

  @override
  void initState() {
    super.initState();
    fetchDetails();
    AutoOrientation.landscapeRightMode();
  }

  Future<void> fetchDetails() async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/${widget.detailType}/${widget.detailItem['id']}?api_key=ec72a0cfeb8618883b5b5afd38d52881&language=pt-BR',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        detailedInfoMap = json.decode(response.body);
      });
    } else {
      throw Exception('Falha ao carregar os detalhes');
    }
  }

  @override
  void dispose() {
    AutoOrientation.fullAutoMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.detailItem['name'] ?? ''),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              getImageUrl(),
              fit: BoxFit.cover,
              height: 400,
              width: double.infinity,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._buildDetailRows([
                    _buildDetailRow(
                        'Título Original', detailedInfoMap['original_title']),
                    _buildDetailRow(
                        'Gêneros', getGenres(detailedInfoMap['genres'] ?? [])),
                    _buildDetailRow('Orçamento', detailedInfoMap['budget']),
                    _buildDetailRow('Tagline', detailedInfoMap['tagline']),
                    _buildDetailRow(
                        'Nota Média', detailedInfoMap['vote_average']),
                    _buildDetailRow(
                        'Número de Votos', detailedInfoMap['vote_count']),
                    _buildDetailRow('Receita', detailedInfoMap['revenue']),
                    _buildDetailRow('Duração', detailedInfoMap['runtime']),
                    _buildDetailRow('Visão Geral', detailedInfoMap['overview']),
                    _buildDetailRow(
                        'Data de Estreia', detailedInfoMap['first_air_date']),
                    _buildDetailRow('Data do Último Episódio',
                        detailedInfoMap['last_air_date']),
                    _buildDetailRow('Nome', detailedInfoMap['name']),
                    _buildDetailRow('Número de Episódios',
                        detailedInfoMap['number_of_episodes']),
                    _buildDetailRow('Número de Temporadas',
                        detailedInfoMap['number_of_seasons']),
                    _buildDetailRow('Biografia', detailedInfoMap['biography']),
                    _buildDetailRow(
                        'Data de Nascimento', detailedInfoMap['birthday']),
                    _buildDetailRow(
                        'Popularidade', detailedInfoMap['popularity']),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailRows(List<Widget> rows) {
    return rows.whereType<Widget>().toList();
  }

  String getImageUrl() {
    if (widget.detailType == 'person') {
      return 'https://image.tmdb.org/t/p/w500${widget.detailItem['profile_path']}';
    } else {
      return 'https://image.tmdb.org/t/p/w500${widget.detailItem['poster_path']}';
    }
  }

  String getGenres(List<dynamic> genres) {
    return genres.map((genre) => genre['name']).join(', ');
  }
}

class TrendingList extends StatefulWidget {
  final String itemType;

  TrendingList({required this.itemType});

  @override
  _TrendingListState createState() => _TrendingListState();
}

class _TrendingListState extends State<TrendingList> {
  List<dynamic> itemList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/trending/${widget.itemType}/week?api_key=ec72a0cfeb8618883b5b5afd38d52881&language=pt-BR',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        itemList = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            navigateToDetailScreen(context, itemList[index], widget.itemType);
          },
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              'https://image.tmdb.org/t/p/w154${itemList[index]['poster_path']}',
            ),
          ),
          title:
              Text(itemList[index]['name'] ?? itemList[index]['title'] ?? ''),
        );
      },
    );
  }

  void navigateToDetailScreen(BuildContext context, dynamic item, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(detailItem: item, detailType: type),
      ),
    );
  }
}

class TrendingPeopleList extends StatefulWidget {
  @override
  _TrendingPeopleListState createState() => _TrendingPeopleListState();
}

class _TrendingPeopleListState extends State<TrendingPeopleList> {
  List<dynamic> peopleList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/trending/person/week?api_key=ec72a0cfeb8618883b5b5afd38d52881&language=pt-BR',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        peopleList = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Falha ao carregar dados');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: peopleList.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            navigateToDetailScreen(context, peopleList[index], 'person');
          },
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              'https://image.tmdb.org/t/p/w154${peopleList[index]['profile_path']}',
            ),
          ),
          title: Text(peopleList[index]['name'] ?? ''),
        );
      },
    );
  }

  void navigateToDetailScreen(BuildContext context, dynamic item, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(detailItem: item, detailType: type),
      ),
    );
  }
}

class SearchTabContent extends StatefulWidget {
  @override
  _SearchTabContentState createState() => _SearchTabContentState();
}

class _SearchTabContentState extends State<SearchTabContent> {
  String searchItemType = 'movie';
  String searchText = '';
  List<dynamic> searchResultsList = [];

  Future<void> performSearch() async {
    final response = await http.get(
      Uri.parse(
        'https://api.themoviedb.org/3/search/$searchItemType?api_key=ec72a0cfeb8618883b5b5afd38d52881&language=pt-BR&query=$searchText',
      ),
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResultsList = json.decode(response.body)['results'];
      });
    } else {
      throw Exception('Falha na busca');
    }
  }

  void resetSearch() {
    setState(() {
      searchText = '';
      searchResultsList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.search), // Ícone de lupa
                onPressed: () {
                  performSearch();
                },
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    resetSearch();
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Digite a palavra-chave',
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Radio(
                    value: 'person',
                    groupValue: searchItemType,
                    onChanged: (value) {
                      resetSearch();
                      setState(() {
                        searchItemType = value.toString();
                      });
                    },
                  ),
                  Text('Pessoas'),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 'movie',
                    groupValue: searchItemType,
                    onChanged: (value) {
                      resetSearch();
                      setState(() {
                        searchItemType = value.toString();
                      });
                    },
                  ),
                  Text('Filmes'),
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: 'tv',
                    groupValue: searchItemType,
                    onChanged: (value) {
                      resetSearch();
                      setState(() {
                        searchItemType = value.toString();
                      });
                    },
                  ),
                  Text('Séries'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: searchResultsList.isEmpty
              ? Center(
                  child: Text(''),
                )
              : ListView.builder(
                  itemCount: searchResultsList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () {
                        navigateToDetailScreen(
                            context, searchResultsList[index], searchItemType);
                      },
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          searchItemType == 'person'
                              ? 'https://image.tmdb.org/t/p/w154${searchResultsList[index]['profile_path']}'
                              : 'https://image.tmdb.org/t/p/w154${searchResultsList[index]['poster_path']}',
                        ),
                      ),
                      title: Text(searchResultsList[index]['name'] ??
                          searchResultsList[index]['title'] ??
                          ''),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void navigateToDetailScreen(BuildContext context, dynamic item, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(detailItem: item, detailType: type),
      ),
    );
  }
}
