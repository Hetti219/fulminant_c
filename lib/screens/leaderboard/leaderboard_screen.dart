import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/leaderboard/leaderboard_bloc.dart';
import '../../blocs/leaderboard/leaderboard_event.dart';
import '../../blocs/leaderboard/leaderboard_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../models/user.dart';
import '../../repositories/leaderboard_repository.dart';

class LeaderboardScreen extends StatefulWidget {
  final bool showScaffold;

  const LeaderboardScreen({super.key, this.showScaffold = false});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (context) => BlocProvider<LeaderboardBloc>(
        create: (_) => LeaderboardBloc(
          leaderboardRepository: context.read<LeaderboardRepository>(),
        ),
        child: const LeaderboardScreen(showScaffold: true),
      ),
    );
  }

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    final authState = context.read<AuthBloc>().state;
    if (authState.status == AuthStatus.authenticated &&
        authState.user != null) {
      context.read<LeaderboardBloc>().add(LoadUserRank(authState.user!.uid));
      context
          .read<LeaderboardBloc>()
          .add(LoadUsersAroundRank(authState.user!.uid));
    }
    context.read<LeaderboardBloc>().add(const LoadTopUsers());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabBar = TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Global', icon: Icon(Icons.public)),
        Tab(text: 'Around You', icon: Icon(Icons.people)),
      ],
    );

    final tabBarView = TabBarView(
      controller: _tabController,
      children: const [
        _GlobalLeaderboardTab(),
        _AroundYouTab(),
      ],
    );

    if (widget.showScaffold) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Leaderboard'),
          bottom: tabBar,
        ),
        body: tabBarView,
      );
    } else {
      return Column(
        children: [
          tabBar,
          Expanded(child: tabBarView),
        ],
      );
    }
  }
}

class _GlobalLeaderboardTab extends StatelessWidget {
  const _GlobalLeaderboardTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        switch (state.status) {
          case LeaderboardStatus.initial:
          case LeaderboardStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case LeaderboardStatus.failure:
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load leaderboard',
              onRetry: () {
                context.read<LeaderboardBloc>().add(const LoadTopUsers());
              },
            );
          case LeaderboardStatus.success:
            if (state.topUsers.isEmpty) {
              return const _EmptyLeaderboardView();
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(const LoadTopUsers());
              },
              child: _LeaderboardList(
                users: state.topUsers,
                showCurrentUserRank: true,
                userRank: state.userRank,
              ),
            );
        }
      },
    );
  }
}

class _AroundYouTab extends StatelessWidget {
  const _AroundYouTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState.status != AuthStatus.authenticated) {
          return const Center(
            child: Text('Please log in to view your ranking'),
          );
        }

        return BlocBuilder<LeaderboardBloc, LeaderboardState>(
          builder: (context, state) {
            if (state.usersAroundRank.isEmpty && state.userRank == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<LeaderboardBloc>()
                    .add(LoadUsersAroundRank(authState.user!.uid));
                context
                    .read<LeaderboardBloc>()
                    .add(LoadUserRank(authState.user!.uid));
              },
              child: Column(
                children: [
                  if (state.userRank != null)
                    _CurrentUserRankCard(userRank: state.userRank!),
                  Expanded(
                    child: _LeaderboardList(
                      users: state.usersAroundRank,
                      showCurrentUserRank: false,
                      highlightUserId: authState.user?.uid,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _CurrentUserRankCard extends StatelessWidget {
  final UserRank userRank;

  const _CurrentUserRankCard({required this.userRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _RankBadge(rank: userRank.rank, isCurrentUser: true),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rank',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    Text(
                      userRank.user.fullName,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${userRank.user.points}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<User> users;
  final bool showCurrentUserRank;
  final UserRank? userRank;
  final String? highlightUserId;

  const _LeaderboardList({
    required this.users,
    required this.showCurrentUserRank,
    this.userRank,
    this.highlightUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount:
          users.length + (showCurrentUserRank && userRank != null ? 1 : 0),
      itemBuilder: (context, index) {
        if (showCurrentUserRank && userRank != null && index == 0) {
          return Column(
            children: [
              _CurrentUserRankCard(userRank: userRank!),
              const Divider(thickness: 2),
              const SizedBox(height: 8),
            ],
          );
        }

        final userIndex =
            showCurrentUserRank && userRank != null ? index - 1 : index;
        final user = users[userIndex];
        final rank = userIndex + 1;
        final isHighlighted = user.id == highlightUserId;

        return _LeaderboardItem(
          user: user,
          rank: rank,
          isHighlighted: isHighlighted,
        );
      },
    );
  }
}

class _LeaderboardItem extends StatelessWidget {
  final User user;
  final int rank;
  final bool isHighlighted;

  const _LeaderboardItem({
    required this.user,
    required this.rank,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: isHighlighted ? 4 : 1,
        color: isHighlighted
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : null,
        child: ListTile(
          leading: _RankBadge(rank: rank, isCurrentUser: isHighlighted),
          title: Text(
            user.fullName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight:
                      isHighlighted ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          subtitle: Text(user.email),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${user.points}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final bool isCurrentUser;

  const _RankBadge({
    required this.rank,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    if (rank == 1) {
      backgroundColor = Colors.amber;
    } else if (rank == 2) {
      backgroundColor = Colors.grey[400]!;
    } else if (rank == 3) {
      backgroundColor = Colors.brown;
    } else if (isCurrentUser) {
      backgroundColor = Theme.of(context).primaryColor;
    } else {
      backgroundColor = Colors.grey[600]!;
    }

    return CircleAvatar(
      backgroundColor: backgroundColor,
      radius: 20,
      child: rank <= 3
          ? Icon(
              rank == 1 ? Icons.emoji_events : Icons.military_tech,
              color: textColor,
              size: 20,
            )
          : Text(
              '$rank',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
    );
  }
}

class _EmptyLeaderboardView extends StatelessWidget {
  const _EmptyLeaderboardView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Rankings Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete courses and activities to appear on the leaderboard!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
