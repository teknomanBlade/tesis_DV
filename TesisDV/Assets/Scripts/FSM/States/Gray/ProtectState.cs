using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProtectState : IState
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
    public ProtectState(StateMachine fsm, Enemy p, Pathfinding pf)
    {
        _fsm = fsm;
        _enemy = p;
        _pf = pf;
    }

    public void OnStart()
    {
        _currentPathWaypoint = 0;

        _enemy.GetProtectTarget();

        //var dir = _enemy._target.transform.position - _enemy.transform.position;  Probar estos dos despues
        //_enemy.transform.forward = dir;                                           Probar estos dos despues

        //GetThetaStar();
        Debug.Log("Entre a Protect");
        //_enemy.ResetPathAndSetObjective(_enemy._target.transform.position);
    }
    public void OnUpdate()
    {
        if (!_enemy._lm.enemyHasObjective)
        {
            _fsm.ChangeState(EnemyStatesEnum.CatState);
        }
        if(Vector3.Distance(_enemy._player.transform.position, _enemy.transform.position) < _enemy.pursueThreshold && _enemy._player.isAlive) //Agregar Raycast para ver al player
        {
            _fsm.ChangeState(EnemyStatesEnum.ChaseState);
        }

        //float distanceToTarget = Vector3.Distance(_enemy.transform.position, _enemy._target.transform.position);
        //Les cuesta tomar el target de nuevo cuando su primer target desaparece. Por ahora funciona pero despues se podria usar el target para
        //que se muevan hacia el cuando el NavmeshPath no sea valido. Para que no se queden duros en el lugar.
        //_enemy.Move();
        if(!_enemy.isDead)
        {
            _enemy._circlePos = AIManager.Instance.RequestPosition(_enemy);
        }

        RaycastHit hit;
        Vector3 protectDir = _enemy._circlePos - _enemy.transform.position;
        if(_enemy._target != null) 
        {
            targetDir = _enemy._target.transform.position - _enemy.transform.position;
        }

        if(!Physics.Raycast(_enemy.transform.position, protectDir, out hit, protectDir.magnitude, _enemy.obstacleMask)) //Usamos obstacle mask ahora.
        {
            if ((Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.5f))
            {
                Vector3 aux = protectDir;
                protectDir = new Vector3(aux.x, 0f, aux.z);
                _enemy.transform.forward = protectDir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
            }
        }
        else if (!Physics.Raycast(_enemy.transform.position, targetDir, out hit, targetDir.magnitude, _enemy.obstacleMask))
        {
            if (_enemy._target != null && (Vector3.Distance(_enemy.transform.position, _enemy._target.transform.position) > 0.5f))
            {
                Vector3 aux = targetDir;
                targetDir = new Vector3(aux.x, 0f, aux.z);
                _enemy.transform.forward = targetDir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;
            }
        }
        else if (myPath != null)
        {
            if(myPath.Count >= 1)
            {
                Vector3 dir = myPath[_currentPathWaypoint].transform.position - _enemy.transform.position;

                _enemy.transform.forward = dir;
                _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime;

                if (dir.magnitude < 0.4f)
                {
                    _currentPathWaypoint++;
                    if (_currentPathWaypoint > myPath.Count - 1)
                    {
                        Debug.Log("No encontré mi objetivo, recalculando.");
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
        /* else if((Vector3.Distance(_enemy.transform.position, _enemy._circlePos) > 0.2f))
        {
             Vector3 aux = protectDir;
            protectDir = new Vector3(aux.x, 0f, aux.z);
            _enemy.transform.forward = protectDir;
            _enemy.transform.position += _enemy.transform.forward * _enemy._movingSpeed * Time.deltaTime; 
        } */
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
        myPath = _pf.ConstructPathThetaStar(endingPoint, startingPoint);
        _enemy.SetPath(myPath); //esto no hace falta, es para testear.
    }
}