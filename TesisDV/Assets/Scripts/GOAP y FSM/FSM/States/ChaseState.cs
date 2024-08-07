using UnityEngine;
using FSM;
using System.Collections;
using System.Linq;

public class ChaseState : MonoBaseState
{
    private PathfindingManager _pfManager;
    private Player _player;
    public float movingSpeed;
    private float _playerDistance;
    private float _attackThreshold = 2.5f;
    private float _disengageThreshold = 10f;

    private bool pathIsCreated;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    private EnemyHealth _myHealth;

    private Node StartingPoint;
    private Node EndingPoint;
    public Node[] myPath;
    private AStar<Node> _aStar;

    public LayerMask wallLayer;

    void Awake()
    {
        _myHealth = GetComponent<EnemyHealth>();
    }

    void Start()
    {
        _pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>();
        canCreatePath = true;
        _player = GameVars.Values.Player;
    }

    private IEnumerator FindPath()
    {
        _aStar.OnPathCompleted += path =>
        {
            myPath = path.ToList().ToArray();
            Debug.Log("Tenemos path");
            pathIsCreated = true;
        };

        _aStar.OnCantCalculate += () =>
        {
            Debug.Log("No path found");
        };

        yield return _aStar.Run(
            StartingPoint,
            node => { return node == EndingPoint; },
            node =>
            {
                var neighbours = node.GetNeighbours();
                return neighbours;
            },
            node =>
            {
                float heuristic = node.GetHeuristic(EndingPoint);
                return heuristic;
            }
        );
    }

    public override void UpdateLoop()
    {
        _playerDistance = Vector3.Distance(_player.transform.position, transform.position);

        var dir = (_player.transform.position - transform.position).normalized;

        if (Physics.Raycast(transform.position, dir, _playerDistance, wallLayer))
        {
            if(canCreatePath)
            {
                StartingPoint = _pfManager.GetClosestNode(transform.position);
                Debug.Log("Empiezo en " + StartingPoint);
                EndingPoint = _pfManager.GetClosestNode(_player.transform.position);
                Debug.Log("Termino en " + EndingPoint);
                _aStar = new AStar<Node>();
                StartCoroutine(FindPath());
                canCreatePath = false;
            }
            Move(); 
        }
        else
        {
            Vector3 dirAux = new Vector3(dir.x, 0, dir.z);
            transform.forward = dirAux;
            transform.position += transform.forward * movingSpeed * Time.deltaTime;
            canCreatePath = true;
            _currentWaypoint = 0;
        }

        // Move();
        
    }

    public override IState ProcessInput()
    {
        // _playerDistance = Vector3.Distance(_player.transform.position, transform.position);

        if (_playerDistance <= _attackThreshold)
        {
            return Transitions["OnAttackState"];
        }
        return this;
    }

    private void Move()
    {
        if (pathIsCreated)
        {
            Vector3 dir = myPath[_currentWaypoint].transform.position - transform.position;
            transform.forward = dir;
            transform.position += transform.forward * movingSpeed * Time.deltaTime;
            _myHealth.SetPosition(transform.position);

            if (dir.magnitude < 0.5f)
            {
                //_currentWaypoint++; Lo sumamos después de verificar.
                if (_currentWaypoint + 1 > myPath.Length) //-1
                {
                    _currentWaypoint = 0;
                    canCreatePath = true;
                }
                else
                {
                    _currentWaypoint++;
                }

            }
        }
    }
}
