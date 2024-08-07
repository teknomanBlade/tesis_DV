using UnityEngine;
using FSM;
using System.Collections;
using System.Linq;

public class FleeingState : MonoBaseState
{
    private PathfindingManager _pfManager;
    public Cat _cat;
    public float movingSpeed;
    public Vector3 _exitPos;
    public float _shipDistance;
    private bool pathIsCreated;
    private int _currentWaypoint = 0;
    private bool canCreatePath;
    private EnemyHealth _myHealth;

    private float distanceToEscape = 5;
    private Node StartingPoint;
    private Node EndingPoint;
    public Node[] myPath;
    private AStar<Node> _aStar;

    void Awake()
    {
        _myHealth = GetComponent<EnemyHealth>();
    }
    
    void Start()
    {
        _pfManager = GameObject.Find("PathfindingManager").GetComponent<PathfindingManager>();
        canCreatePath = true;
        Vector3 aux = new Vector3(transform.position.x, 0f, transform.position.z);
        _exitPos = aux;
        _cat = GameVars.Values.Cat;
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

        if (_cat != null)
            _cat.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);

        if (_myHealth._hasCat && canCreatePath)
        {
            StartingPoint = _pfManager.GetClosestNode(transform.position);
            Debug.Log("Empiezo en " + StartingPoint);
            EndingPoint = _pfManager.GetClosestNode(_exitPos);
            Debug.Log("Termino en " + EndingPoint);
            _aStar = new AStar<Node>();
            StartCoroutine(FindPath());
            canCreatePath = false;
        }

        Move();
    }

    public override IState ProcessInput()
    {
        _shipDistance = Vector3.Distance(_exitPos, transform.position);
        if (_shipDistance < distanceToEscape)
        {
            pathIsCreated = false;
            if (_cat != null)
            {
                Destroy(_cat.gameObject);
            }

            return Transitions["OnChaseState"];
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
                    pathIsCreated = false;
                }
                else
                {
                    _currentWaypoint++;
                }

            }
        }
    }
}
