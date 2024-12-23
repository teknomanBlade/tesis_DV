using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GrayDogProtectState : IState
{

    private StateMachine _fsm;
    private Pathfinding _pf;
    private Enemy _enemy;

    private bool foundCircle = false;
    private bool canPathfind;
    public List<Node> myPath;
    private int _currentWaypoint;
    private int _currentPathWaypoint = 0;
    private Node startingPoint;
    private Node endingPoint;
    private Vector3 targetDir;
    public GrayDogProtectState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    

    public void OnStart()
    {
        _currentPathWaypoint = 0;

        _enemy.GetProtectTarget();

        Debug.Log("Entre a GrayDogProtect");
    }

    public void OnUpdate()
    {
        if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }

        //float distanceToTarget = Vector3.Distance(_enemy.transform.position, _enemy._target.transform.position);
        //Les cuesta tomar el target de nuevo cuando su primer target desaparece. Por ahora funciona pero despues se podria usar el target para
        //que se muevan hacia el cuando el NavmeshPath no sea valido. Para que no se queden duros en el lugar.
        //_enemy.Move();
        if (!_enemy.isDead)
        {
            _enemy._circlePos = AIManager.Instance.RequestPosition(_enemy);
        }

        RaycastHit hit;
        Vector3 protectDir = _enemy._circlePos - _enemy.transform.position;
        if (_enemy._target != null)
        {
            targetDir = _enemy._target.transform.position - _enemy.transform.position;
        }

        if (!Physics.Raycast(_enemy.transform.position, protectDir, out hit, protectDir.magnitude, _enemy.obstacleMask)) //Usamos obstacle mask ahora.
        {
            if ((Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.5f))
            {
                Vector3 aux = protectDir;
                protectDir = new Vector3(aux.x, 0f, aux.z);
                _enemy.transform.forward = protectDir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
            }
        }
        else if (myPath != null)
        { 
            if (myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.4f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        Debug.Log("No encontr� mi objetivo, recalculando.");
                        _currentPathWaypoint = 0;
                        GetThetaStar();
                    }
                }
            }
        }
        else
        {
            GetThetaStar();
        }
    }
    public void OnExit()
    {
        Debug.Log("Sali de Protect");
    }

    public void GetThetaStar()
    {
        myPath = new List<Node>();

        startingPoint = PathfindingManager.Instance.GetClosestNode(_enemy.transform.position);

        _currentWaypoint = _enemy.GetCurrentWaypoint();

        endingPoint = PathfindingManager.Instance.GetClosestNode(_enemy._target.transform.position);

        //myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        myPath = _pf.ConstructPathAStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }

}
